// ignore_for_file: avoid_print
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:sana_mobile/screen/chatroom_screen.dart';
import 'package:sana_mobile/services/chat_services.dart';
import 'package:sana_mobile/services/socket_services.dart';
import 'package:sana_mobile/services/user_services.dart';
import 'package:intl/intl.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  String? myId = "";
  List chatrooms = [];
  String publicApiUrl = "";
  late StreamSubscription<String> _messageSubscription;
  // late WebSocketChannel _channel;
  // void _getInitialInfo() {
  //   chats = ChatModel.getChats();
  // }

  @override
  void initState() {
    super.initState();
    _websocketConnect();
    String apiUrl = UserServices.apiUrl();
    setState(() {
      publicApiUrl = "$apiUrl/public/";
    });

    fetchChatroom();
  }

  Future<void> _websocketConnect() async {
    _messageSubscription = SocketService().messageStream.listen((message) {
      print("socket msg: $message");
      fetchChatroom();
      // if (SocketService().shouldTriggerApiCall(message)) {
      //   _fetchProfileData(); // Call the API when the condition is met
      // }
    });
  }

  @override
  void dispose() {
    _messageSubscription.cancel(); // Cancel the subscription
    super.dispose();
  }

  String formatDateTime(String dateTimeString) {
    DateTime parsedDate = DateTime.parse(dateTimeString);
    DateTime today = DateTime.now();

    // Cek apakah tanggalnya adalah hari ini
    if (parsedDate.year == today.year &&
        parsedDate.month == today.month &&
        parsedDate.day == today.day) {
      // Jika hari ini, tampilkan jam dalam format WIB (GMT+7)
      var timeFormat = DateFormat('HH:mm');
      return timeFormat.format(parsedDate);
    } else {
      // Jika bukan hari ini, tampilkan dalam format DD/MM/YY
      var dateFormat = DateFormat('dd/MM/yy');
      return dateFormat.format(parsedDate);
    }
  }

  @override
  Widget build(BuildContext context) {
    // _getInitialInfo();
    return Scaffold(
        appBar: AppBar(
          title: const Text(
            "Chats",
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
          // actions: [_newChat()],
        ),
        body: _chats());
  }

  Padding _newChat() {
    return Padding(
        padding: const EdgeInsets.only(right: 20),
        child: GestureDetector(
          onTap: () {
            print('Add new chat');
          },
          child: const Icon(
            Icons.add_circle_outline,
            size: 35,
          ),
        ));
  }

  ListView _chats() {
    return ListView.separated(
      itemCount: chatrooms.length,
      shrinkWrap: true,
      separatorBuilder: (context, index) => const SizedBox(
        height: 10,
      ),
      padding: const EdgeInsets.only(left: 10, right: 10),
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () {
            print('chat name : ${chatrooms[index]['receiverdata']['name']}');
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => ChatroomScreen(room: chatrooms[index])),
            );
          },
          onDoubleTap: () {
            print('last chat : ${chatrooms[index]['message']}');
          },
          child: Container(
              height: 100,
              padding: const EdgeInsets.only(left: 5),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(15),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      chatrooms[index]['receiverdata']['picture'] == ""
                          ? const CircleAvatar(
                              radius: 35,
                              backgroundColor: Colors.lightBlue,
                              child: Icon(Icons.person))
                          : CircleAvatar(
                              backgroundImage: NetworkImage(publicApiUrl +
                                  chatrooms[index]['receiverdata']['picture']),
                              radius: 35,
                            ),
                      const SizedBox(
                        width: 10,
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            chatrooms[index]['receiverdata']['name'],
                            style: const TextStyle(
                                fontWeight: FontWeight.w500,
                                color: Colors.black,
                                fontSize: 16),
                          ),
                          Text(
                            chatrooms[index]['message'],
                            style: const TextStyle(
                                color: Color(0xff7B6F72),
                                fontSize: 13,
                                fontWeight: FontWeight.w400),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Column(
                    // mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Padding(
                          padding: const EdgeInsets.only(right: 10, top: 10),
                          child: Text(
                              formatDateTime(chatrooms[index]['newchat_at']))),
                      if (chatrooms[index]['unreadmsg'] > 0)
                        Padding(
                          padding: const EdgeInsets.only(right: 10, top: 10),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                                color: Colors.blue, shape: BoxShape.circle),
                            constraints: const BoxConstraints(
                              minWidth: 20,
                              minHeight: 20,
                            ),
                            child: Text(
                              '${chatrooms[index]['unreadmsg']}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        )
                    ],
                  )
                ],
              )),
        );
      },
    );
  }

  Future<void> fetchChatroom() async {
    final response = await ChatServices.fetchChatrooms(1, 15, true);
    if (response != null) {
      setState(() {
        chatrooms = response['data'];
      });
    } else {
      // const SnackBar(content: Text("Something went Wrong"));
    }
  }
}
