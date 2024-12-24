import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:sana_mobile/screen/merchant_screen.dart';
import 'package:sana_mobile/shared/logout.dart';

class ProfileTopbar extends StatelessWidget implements PreferredSizeWidget {
  const ProfileTopbar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text(
        "Profile",
        style: TextStyle(fontWeight: FontWeight.w800),
      ),
      actions: <Widget>[
        IconButton(
            onPressed: () {
              print('Merchant page');
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const MerchantScreen()),
              );
            },
            icon: const Icon(Icons.store_outlined)),
        IconButton(
          icon: const Icon(Icons.menu),
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
            child: Padding(
                padding: const EdgeInsets.only(left: 20, top: 20),
                child: Column(
                  // mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    // ignore: avoid_unnecessary_containers
                    Container(
                        height: 40,
                        decoration: const BoxDecoration(color: Colors.white),
                        width: MediaQuery.of(context).size.width,
                        child: const Align(
                            alignment: Alignment.topCenter,
                            child: Text('Menu',
                                style:
                                    TextStyle(fontWeight: FontWeight.bold)))),
                    GestureDetector(
                        onTap: () {
                          print('Add post');
                        },
                        child: Container(
                            height: 30,
                            decoration:
                                const BoxDecoration(color: Colors.white),
                            width: MediaQuery.of(context).size.width,
                            child: const Row(
                              children: [
                                Icon(Icons.add_a_photo_outlined),
                                Padding(
                                  padding: EdgeInsets.only(left: 5),
                                  child: Text("Add post"),
                                )
                              ],
                            ))),
                    Divider(color: Colors.grey[100]),
                    GestureDetector(
                        onTap: () {
                          print("Merchant");
                        },
                        child: Container(
                            height: 30,
                            decoration:
                                const BoxDecoration(color: Colors.white),
                            child: const Row(
                              children: [
                                Icon(Icons.store_outlined),
                                Padding(
                                  padding: EdgeInsets.only(left: 5),
                                  child: Text("Merchant"),
                                )
                              ],
                            ))),
                    Divider(color: Colors.grey[100]),
                    ElevatedButton(
                      child: const Text('Logout'),
                      onPressed: () {
                        showLogoutConfirmDialog(context);
                      },
                    ),
                  ],
                )));
      },
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

// class ProfileTopbar extends StatelessWidget {
// const ProfileTopbar({ Key? key }) : super(key: key);

//   @override
//   Widget build(BuildContext context){

//   }
// }

// class ProfileTopbar extends StatefulWidget {
//   const ProfileTopbar({Key? key}) : super(key: key);

//   @override
//   // _ProfileTopbarState createState() => _ProfileTopbarState();
//   State<ProfileTopbar> createState() => _ProfileTopbarState();
// }

// class _ProfileTopbarState extends State<ProfileTopbar> {
//   @override
//   Widget build(BuildContext context) {
    
//   }

  
// }
