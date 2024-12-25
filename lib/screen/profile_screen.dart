import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sana_mobile/screen/changepass_screen.dart';
import 'package:sana_mobile/screen/profileupdate_screen.dart';
import 'package:sana_mobile/services/user_services.dart';
import 'package:sana_mobile/shared/logout.dart';
import 'package:sana_mobile/services/socket_services.dart';

class ProfileScreen extends StatefulWidget {
  // final Map user;
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map userData = {};
  String publicApiUrl = "";
  late StreamSubscription<String> _messageSubscription;
  bool isLoad = true;
  String? myId = '';

  @override
  void initState() {
    super.initState();
    String apiUrl = UserServices.apiUrl();
    setState(() {
      publicApiUrl = "$apiUrl/public/";
    });

    fetchuserData();
    _websocketConnect();
  }

  Future<void> _websocketConnect() async {
    String? userId = await UserServices.checkMyId();
    setState(() {
      myId = userId;
    });
    _messageSubscription = SocketService().messageStream.listen((message) {
      print("socket msg mymerchant: $message");
      if (message == "myMerchant$myId") {
        fetchuserData();
      }
    });
  }

  Future<void> _refresh() async {
    fetchuserData();
  }

  @override
  void dispose() {
    super.dispose();
    _messageSubscription.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // automaticallyImplyLeading: false,
        title: const Text(
          'Profile',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        centerTitle: false,
      ),
      body: userData.isEmpty
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : userProfile(context),
    );
  }

  Column userProfile(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Center(
              child: userData['picture'] == ""
                  ? const CircleAvatar(
                      radius: 80,
                      child: Icon(Icons.person_outlined, size: 80),
                    )
                  : CircleAvatar(
                      backgroundImage:
                          NetworkImage(publicApiUrl + userData['picture']),
                      radius: 80,
                    ),
            )),
        Center(
          child: SizedBox(
              height: 80,
              width: MediaQuery.of(context).size.width - 160,
              // decoration: BoxDecoration(color: Colors.grey[50]),
              child: Center(
                child: Text(
                  userData['name'],
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w500),
                ),
              )),
        ),
        Padding(
            padding: const EdgeInsets.only(left: 20, top: 20, right: 20),
            child: SizedBox(
                height: MediaQuery.of(context).size.height - 370,
                width: MediaQuery.of(context).size.width,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Column(
                      children: [
                        GestureDetector(
                            onTap: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => ProfileupdateScreen(
                                          name: userData["name"],
                                          userId: userData["ID"],
                                          pathImage: userData["picture"],
                                        )),
                              );
                              _refresh();
                            },
                            child: const SizedBox(
                                height: 30,
                                child: Row(
                                  children: [
                                    Icon(Icons.edit_note_outlined),
                                    Padding(
                                      padding: EdgeInsets.only(left: 5),
                                      child: Text("Edit Profile"),
                                    )
                                  ],
                                ))),
                        Divider(color: Colors.grey[100]),
                        GestureDetector(
                          onTap: () async {
                            await Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => ChangepassScreen(
                                        userId: userData["ID"])));
                            _refresh();
                          },
                          child: SizedBox(
                            height: 30,
                            width: MediaQuery.of(context).size.width,
                            child: const Row(
                              children: [
                                Icon(Icons.lock_outline),
                                Padding(
                                  padding: EdgeInsets.only(left: 5),
                                  child: Text("Change Password"),
                                )
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    GestureDetector(
                        onTap: () {
                          print("logout?");
                          showLogoutConfirmDialog(context);
                        },
                        child: SizedBox(
                            height: 30,
                            width: MediaQuery.of(context).size.width,
                            child: const Row(
                              children: [
                                Icon(
                                  Icons.logout_outlined,
                                  color: Colors.red,
                                ),
                                Padding(
                                  padding: EdgeInsets.only(left: 5),
                                  child: Text(
                                    "Logout",
                                    style: TextStyle(color: Colors.red),
                                  ),
                                )
                              ],
                            ))),
                  ],
                )))
      ],
    );
  }

  Future<void> fetchuserData() async {
    setState(() {
      isLoad = true;
    });
    print("fetch user profile");
    final response = await UserServices.fetchUsers();
    if (response != null) {
      setState(() {
        userData = response['data'];
      });
    } else {
      // const SnackBar(content: Text("Something went Wrong"));
    }
    setState(() {
      isLoad = false;
    });
  }
}
