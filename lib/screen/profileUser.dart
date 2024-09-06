// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:sana_mobile/models/image_model.dart';
import 'package:sana_mobile/screen/image_viewer_screen.dart';
import 'package:sana_mobile/services/user_services.dart';
import 'package:sana_mobile/shared/profile_topbar.dart';

class ProfileUserScreen extends StatefulWidget {
  const ProfileUserScreen({super.key});

  @override
  State<ProfileUserScreen> createState() => _ProfileUserScreenState();
}

class _ProfileUserScreenState extends State<ProfileUserScreen> {
  List users = [];
  int totalData = 0;
  List<ImageModel> images = [];

  void _getInitialInfo() {
    images = ImageModel.getImages();
  }

  @override
  void initState() {
    super.initState();
    _getInitialInfo();
    // fetchUser();
  }

  Future<void> _refresh() async {
    _getInitialInfo();
  }

  @override
  Widget build(BuildContext context) {
    // _getInitialInfo();
    return Scaffold(
        appBar: const ProfileTopbar(),
        body: RefreshIndicator(
            onRefresh: _refresh,
            child: images.isEmpty ? _emptyImageLibrary() : _listViewContent()));
  }

  Column _emptyImageLibrary() {
    return Column(
      children: [
        _profileData(),
        const SizedBox(height: 10),
        const Center(
            child: Text(
          "Share your moment",
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
        ))
      ],
    );
  }

  _listViewContent() {
    return ListView.builder(
      itemCount: images.length,
      padding: const EdgeInsets.only(top: 0),
      itemBuilder: (context, index) {
        int totalList = (images.length / 3).round();
        print("total list image library: $totalList");
        if (index <= totalList) {
          if (index == 0) {
            return Column(children: [
              _profileData(),
              _imageLibrary(index),
              // _imageList(index)
            ]);
          } else {
            return _imageLibrary(index);
            // return _imageList(index);
          }
        } else {
          return const SizedBox.shrink();
        }
      },
    );
  }

  _imageLibrary(index) {
    int itemNumber = _itemNumber(index);
    int idxRow1 = itemNumber;
    int idxRow2 = itemNumber + 1;
    int idxRow3 = itemNumber + 2;
    return SizedBox(
      height: 132,
      // decoration: BoxDecoration(color: Colors.blue[200]),
      child: Row(
        children: [
          SizedBox(
            height: 130,
            // decoration: BoxDecoration(color: Colors.green[200]),
            width: (MediaQuery.of(context).size.width / 3) - 1,
            child: idxRow1 < images.length
                ? GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ImageViewerScreen(
                            images: images, // Daftar ImageModel Anda
                            initialIndex: idxRow1, // Indeks gambar yang diklik
                          ),
                        ),
                      );
                    },
                    child: Image.asset(
                      images[idxRow1].photo,
                      fit: BoxFit.cover,
                    ),
                  )
                : null,
          ),
          const SizedBox(
            width: 1,
          ),
          SizedBox(
            height: 130,
            width: (MediaQuery.of(context).size.width / 3) - 1,
            child: idxRow2 < images.length
                ? GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ImageViewerScreen(
                            images: images, // Daftar ImageModel Anda
                            initialIndex: idxRow2, // Indeks gambar yang diklik
                          ),
                        ),
                      );
                    },
                    child: Image.asset(
                      images[idxRow2].photo,
                      fit: BoxFit.cover,
                    ),
                  )
                : null,
          ),
          const SizedBox(
            width: 1,
          ),
          SizedBox(
            height: 130,
            width: (MediaQuery.of(context).size.width / 3) - 1,
            child: idxRow3 < images.length
                ? GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ImageViewerScreen(
                            images: images, // Daftar ImageModel Anda
                            initialIndex: idxRow3, // Indeks gambar yang diklik
                          ),
                        ),
                      );
                    },
                    child: Image.asset(
                      images[idxRow3].photo,
                      fit: BoxFit.cover,
                    ),
                  )
                : null,
          ),
        ],
      ),
    );
  }

  int _itemNumber(index) {
    var itemNumber = index;
    if (index != 0) {
      if (itemNumber % 2 == 0) {
        //genap
        itemNumber = itemNumber + (index + itemNumber);
      } else {
        //ganjil
        itemNumber = itemNumber + (index + itemNumber);
      }
    }
    return itemNumber;
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
        children: [_profile()],
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
            SizedBox(
                child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                    height: 70,
                    width: 70,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(100)),
                    child: const CircleAvatar(
                      backgroundImage: NetworkImage(
                          'https://buffer.com/library/content/images/size/w1200/2023/10/free-images.jpg'),
                      radius: 50,
                    )
                    // const Icon(Icons.person),
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
