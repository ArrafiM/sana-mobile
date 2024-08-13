// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:sana_mobile/services/user_services.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  List users = [];
  int totalData = 0;

  @override
  void initState() {
    super.initState();
    // fetchUser();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          toolbarHeight: 0,
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _profileData(),
            const SizedBox(
              height: 10,
            ),
            // _myLibrary()
          ],
        ));
  }

  Container _myLibrary() {
    return Container(
        height: 585,
        decoration: BoxDecoration(
            // color: Colors.red[400],
            borderRadius: BorderRadius.circular(10)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 585,
              decoration: BoxDecoration(
                  // color: Colors.blue[300],
                  borderRadius: BorderRadius.circular(10)),
              child: ListView.builder(
                  itemCount: 6,
                  itemBuilder: (context, index) {
                    // final item = users[index] as Map;
                    int itemNumber = index;
                    if (index != 0) {
                      if (itemNumber % 2 == 0) {
                        //genap
                        itemNumber = itemNumber + (index + itemNumber);
                      } else {
                        //ganjil
                        itemNumber = itemNumber + (index + itemNumber);
                      }
                    }
                    return SizedBox(
                      height: 131,
                      // decoration: BoxDecoration(
                      //   color: Colors.green[300],
                      //   borderRadius: BorderRadius.circular(10)
                      // ),
                      child: Row(
                        children: [
                          Container(
                            height: 130,
                            width: 130,
                            decoration: BoxDecoration(
                              color: Colors.blue[200],
                              // borderRadius: BorderRadius.circular(10),
                              // border: const Border(
                              //   right:
                              //       BorderSide(color: Colors.white, width: 1),
                              //   bottom:
                              //       BorderSide(color: Colors.white, width: 1),
                              // )
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(10),
                              child: Text('$itemNumber'),
                            ),
                          ),
                          const SizedBox(
                            width: 1,
                          ),
                          Container(
                            height: 130,
                            width: 130,
                            decoration: BoxDecoration(
                              color: Colors.blue[200],
                              // borderRadius: BorderRadius.circular(10),
                              // border: const Border(
                              //   right:
                              //       BorderSide(color: Colors.white, width: 1),
                              //   bottom:
                              //       BorderSide(color: Colors.white, width: 1),
                              // )
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(10),
                              child: Text('${itemNumber + 1}'),
                            ),
                          ),
                          const SizedBox(
                            width: 1,
                          ),
                          Container(
                            height: 130,
                            width: 130,
                            decoration: BoxDecoration(
                              color: Colors.blue[200],
                              // borderRadius: BorderRadius.circular(10),
                              // border: const Border(
                              //     bottom: BorderSide(
                              //         color: Colors.white, width: 1))
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(10),
                              child: Text('${itemNumber + 2}'),
                            ),
                          )
                        ],
                      ),
                      // child: ListTile(
                      //   leading: CircleAvatar(
                      //     child: Text('${index + 1}'),
                      //   ),
                      //   title: Text(item['email']),
                      //   subtitle: Text(item['birth_date'] ?? '-'),
                      // ),
                    );
                  }),
            ),
          ],
        ));
  }

  Container _profileData() {
    return Container(
      height: 110,
      decoration: BoxDecoration(
          // color: Colors.blue,
          borderRadius: BorderRadius.circular(10)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 10),
            child: Text(
              'Profile',
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.w600),
            ),
          ),
          _profile()
        ],
      ),
    );
  }

  Container _profile() {
    return Container(
      height: 80,
      padding: const EdgeInsets.only(left: 10, right: 10, top: 10),
      child: Container(
        decoration: BoxDecoration(
            // color: Colors.blue[300],
            borderRadius: BorderRadius.circular(10)),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
                height: 70,
                width: 70,
                decoration: BoxDecoration(
                    color: Colors.blue[900],
                    borderRadius: BorderRadius.circular(100)),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      height: 60,
                      width: 60,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(100)),
                      child: const Icon(Icons.person),
                    ),
                  ],
                )),
            const Padding(
                padding: EdgeInsets.only(left: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Hello, Rafi!",
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                    ),
                    Text("@kasep"),
                  ],
                ))
          ],
        ),
      ),
    );
  }

  Future<void> fetchUser() async {
    final response = await UserServices.fetchUsers();
    if (response != null) {
      setState(() {
        users = response['data'];
        totalData = response['total_list'];
      });
    } else {
      // const SnackBar(content: Text("Something went Wrong"));
    }
  }
}
