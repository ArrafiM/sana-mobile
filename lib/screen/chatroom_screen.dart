import 'dart:async';
import 'package:flutter/material.dart';
import 'package:sana_mobile/services/chat_services.dart';
import 'package:sana_mobile/services/socket_services.dart';
import 'package:sana_mobile/services/user_services.dart';
// import 'package:web_socket_channel/status.dart' as status;

class ChatroomScreen extends StatefulWidget {
  final Map room;
  const ChatroomScreen({Key? key, required this.room}) : super(key: key);

  @override
  State<ChatroomScreen> createState() => _ChatroomScreenState();
}

class _ChatroomScreenState extends State<ChatroomScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, dynamic>> _messages = [];
  late StreamSubscription<String> _messageSubscription;
  int roomId = 0;
  Map roomData = {};
  String publicApiUrl = "";
  String? myId = "";
  int receiverId = 0;
  //nextpage
  final ScrollController _scrollController = ScrollController();
  int _currentPage = 1; // Menyimpan halaman saat ini
  bool _isLoading = false;
  bool _hasMoreData = true;

  @override
  void initState() {
    super.initState();

    // Ambil informasi dari room
    Map room = widget.room;
    if (room.isNotEmpty) {
      String apiUrl = UserServices.apiUrl();
      setState(() {
        roomId = room['ID'];
        roomData = room;
        publicApiUrl = "$apiUrl/public/";
        receiverId = room['receiverdata']['id'];
      });
    }
    if (room['ID'] != 0) {
      _websocketConnect();
    }

    _fetchChatData(
        _currentPage, 15, false, true); // Ambil data chat saat pertama kali

    // Tambahkan listener pada scroll controller untuk mendeteksi event scroll
    _scrollController.addListener(_onScroll);
  }

  Future<void> _websocketConnect() async {
    String? userId = await UserServices.checkMyId();
    setState(() {
      myId = userId;
    });
    _messageSubscription = SocketService().messageStream.listen((message) {
      print("socket msg: $message");
      if (message == "chatRoomId$roomId") {
        setState(() {
          _hasMoreData = true;
        });
        _fetchChatData(1, 1, true, true);
      }
    });
  }

  void _onScroll() {
    // Hanya hit API jika scroll mencapai posisi paling data terakhir
    if (_scrollController.position.pixels ==
            _scrollController.position.maxScrollExtent &&
        !_isLoading) {
      _fetchChatData(_currentPage + 1, 15, false, false);
    }
  }

  Future<void> _fetchChatData(page, limit, isNew, readMsg) async {
    print("roomId: $roomId");
    if (_isLoading || !_hasMoreData) {
      return; // Cegah multiple request atau jika tidak ada data lebih
    }
    if (roomId == 0) {
      return;
    }

    setState(() {
      _isLoading = true; // Menandai bahwa data sedang dimuat
    });

    final response =
        await ChatServices.fetchChattings(roomId, page, limit, readMsg);
    if (response != null) {
      final data = response['data'] as List;
      setState(() {
        if (data.isNotEmpty) {
          // Tambahkan data baru di bagian awal list, tanpa menghapus data lama
          if (!isNew) {
            _messages.addAll(data
                .map((msg) => {
                      'text': msg['message'] as String,
                      'sender_id': msg['sender_id'] as int,
                    })
                .toList());
            _currentPage = page; // Update halaman saat ini
          } else {
            _messages.insertAll(
                0,
                data
                    .map((msg) => {
                          'text': msg['message'] as String,
                          'sender_id': msg['sender_id'] as int,
                        })
                    .toList());
          }

          // Jika data yang dimuat kurang dari limit, tandai bahwa tidak ada data lebih
          if (data.length < limit) _hasMoreData = false;
        } else {
          _hasMoreData = false; // Tidak ada data lebih untuk dimuat
        }
        _isLoading = false; // Set loading selesai
      });
    } else {
      setState(() {
        _isLoading = false; // Set loading selesai jika terjadi error
      });
      throw Exception('Failed to load chats');
    }
  }

  void _sendMessage() {
    if (_controller.text.isNotEmpty) {
      _storeMessage(receiverId, _controller.text);
      _controller.clear();
    }
  }

  @override
  void dispose() {
    if (roomId != 0) {
      _messageSubscription.cancel();
    }
    _scrollController
        .dispose(); // Jangan lupa dispose controller saat screen ditutup
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
        roomData['receiverdata']['picture'] == ""
            ? const CircleAvatar(
                radius: 20,
                backgroundColor: Colors.lightBlue,
                child: Icon(Icons.person))
            : CircleAvatar(
                backgroundImage: NetworkImage(
                    publicApiUrl + roomData['receiverdata']['picture']),
                radius: 20,
              ),
        const SizedBox(
          width: 10,
        ),
        Text(roomData['receiverdata']['name'])
      ])),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              reverse: true, // Untuk menampilkan pesan terbaru di bawah
              controller: _scrollController,
              itemCount: _messages.length +
                  (_isLoading ? 1 : 0), // Tambahkan 1 untuk indikator loading
              itemBuilder: (context, index) {
                if (index == _messages.length) {
                  return _buildLoadingIndicator(); // Tampilkan loading saat memuat data tambahan
                }
                return _buildMessageBubble(_messages[index]);
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration:
                        const InputDecoration(labelText: 'Send a message...'),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(Map<String, dynamic> message) {
    bool isSender =
        true; // Optional: Untuk menentukan pesan dikirim atau diterima
    if ("${message['sender_id']}" != myId) isSender = false;
    return Align(
      alignment: isSender ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSender ? Colors.blueAccent : Colors.grey[300],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          message['text'],
          style: TextStyle(
            color: isSender ? Colors.white : Colors.black87,
          ),
        ),
      ),
    );
  }

  // Widget untuk indikator loading saat mengambil data
  Widget _buildLoadingIndicator() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(8.0),
        child: CircularProgressIndicator(),
      ),
    );
  }

  void _newRoom(newRoomId) {
    setState(() {
      roomId = newRoomId;
    });
    _websocketConnect();
  }

  Future<void> _storeMessage(receiverId, msg) async {
    final response = await ChatServices.sendMessage(receiverId, msg);
    if (response != null) {
      final data = response['data'] as Map;
      setState(() {
        _hasMoreData = true;
      });
      if (roomId == 0) {
        _newRoom(data['chatroom_id']);
      }
      _fetchChatData(1, 1, true, false);
      print("send new message!: $data");
    } else {
      throw Exception('Failed to load chats');
    }
  }
}
