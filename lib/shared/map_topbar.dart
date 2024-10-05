import 'dart:async';
import 'package:flutter/material.dart';
import 'package:sana_mobile/screen/chat_screen.dart';
import 'package:sana_mobile/services/chat_services.dart';
import 'package:sana_mobile/services/socket_services.dart';
import 'package:sana_mobile/shared/logout.dart';

class MapTopbar extends StatefulWidget implements PreferredSizeWidget {
  const MapTopbar({super.key});

  @override
  State<MapTopbar> createState() => _MapTopbarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _MapTopbarState extends State<MapTopbar> {
  int unreadMessage = 0;
  late StreamSubscription<String> _messageSubscription;

  @override
  void initState() {
    super.initState();
    _websocketConnect();
    fetchChatroom();
  }

  Future<void> _websocketConnect() async {
    _messageSubscription = SocketService().messageStream.listen((message) {
      print("socket msg: $message");
      fetchChatroom();
    });
  }

  @override
  void dispose() {
    _messageSubscription.cancel(); // Cancel the subscription
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text(
        "SANA",
        style: TextStyle(fontWeight: FontWeight.w800),
      ),
      actions: <Widget>[
        Stack(
          children: <Widget>[
            IconButton(
              icon: const Icon(Icons.question_answer),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ChatScreen()),
                );
              },
            ),
            if (unreadMessage > 0)
              Positioned(
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                      color: Colors.red, shape: BoxShape.circle),
                  constraints: const BoxConstraints(
                    minWidth: 20,
                    minHeight: 20,
                  ),
                  child: Text(
                    '$unreadMessage',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
        IconButton(
          icon: const Icon(Icons.more_horiz),
          onPressed: () {
            // Aksi saat tombol notifications ditekan
            showModalSheet(context, null);
          },
        ),
      ],
    );
  }

  void showModalSheet(BuildContext context, data) {
    // if (data != null) {
    //   print("modal dengan data: $data");
    // }
    showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 400,
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(16)),
          child: Column(
            // mainAxisAlignment: MainAxisAlignment.center,
            // mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // ignore: avoid_unnecessary_containers
              Container(
                padding: const EdgeInsets.only(top: 20, left: 20),
                child: const Text('Modal BottomSheet'),
              ),
              ElevatedButton(
                child: const Text('Close BottomSheet'),
                onPressed: () => Navigator.pop(context),
              ),
              ElevatedButton(
                child: const Text('Logout'),
                onPressed: () {
                  showLogoutConfirmDialog(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> fetchChatroom() async {
    final response = await ChatServices.fetchChatrooms(1, 15, false);
    if (response != null) {
      setState(() {
        unreadMessage = response['unread'];
      });
    } else {
      // const SnackBar(content: Text("Something went Wrong"));
    }
  }
}
