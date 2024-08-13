// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:sana_mobile/models/chat_model.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  List<ChatModel> chats = [];

  void _getInitialInfo() {
    chats = ChatModel.getChats();
  }

  @override
  Widget build(BuildContext context) {
    _getInitialInfo();
    return Scaffold(
        appBar: AppBar(
          title: const Text(
            "Chats",
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
          actions: [_newChat()],
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
      itemCount: chats.length,
      shrinkWrap: true,
      separatorBuilder: (context, index) => const SizedBox(
        height: 10,
      ),
      padding: const EdgeInsets.only(left: 10, right: 10),
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () {
            print('chat name : ${chats[index].name}');
          },
          onDoubleTap: () {
            print('last chat : ${chats[index].lastChat}');
          },
          child: Container(
            height: 100,
            padding: const EdgeInsets.only(left: 5),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              // borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  width: 85,
                  height: 85,
                  decoration: BoxDecoration(
                      color: Colors.blue[100], shape: BoxShape.circle
                      // borderRadius: BorderRadius.circular(16)
                      ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Container(
                        width: 70,
                        height: 70,
                        decoration: const BoxDecoration(
                            color: Colors.white, shape: BoxShape.circle),
                        child: Padding(
                            padding: const EdgeInsets.all(2.0),
                            child: CircleAvatar(
                                backgroundImage:
                                    AssetImage(chats[index].photo))),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      chats[index].name,
                      style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                          fontSize: 16),
                    ),
                    Text(
                      chats[index].lastChat,
                      style: const TextStyle(
                          color: Color(0xff7B6F72),
                          fontSize: 13,
                          fontWeight: FontWeight.w400),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
