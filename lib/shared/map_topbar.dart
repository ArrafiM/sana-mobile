import 'package:flutter/material.dart';
import 'package:sana_mobile/screen/chat_screen.dart';
import 'package:sana_mobile/shared/logout.dart';

class MapTopbar extends StatelessWidget implements PreferredSizeWidget {
  const MapTopbar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text(
        "SANA",
        style: TextStyle(fontWeight: FontWeight.w800),
      ),
      actions: <Widget>[
        IconButton(
          icon: const Icon(Icons.question_answer),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ChatScreen()),
            );
          },
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

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

// class MapTopbar extends StatelessWidget {
// const MapTopbar({ Key? key }) : super(key: key);

//   @override
//   Widget build(BuildContext context){

//   }
// }

// class MapTopbar extends StatefulWidget {
//   const MapTopbar({Key? key}) : super(key: key);

//   @override
//   // _MapTopbarState createState() => _MapTopbarState();
//   State<MapTopbar> createState() => _MapTopbarState();
// }

// class _MapTopbarState extends State<MapTopbar> {
//   @override
//   Widget build(BuildContext context) {
    
//   }

  
// }
