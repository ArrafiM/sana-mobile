// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:sana_mobile/models/image_model.dart';
import 'package:sana_mobile/screen/image_viewer_screen.dart';
import 'package:sana_mobile/services/user_services.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  List users = [];
  int totalData = 0;
  List<ImageModel> images = [];

  void _getInitialInfo() {
    images = ImageModel.getImages();
  }

  @override
  void initState() {
    super.initState();
    // fetchUser();
  }

  @override
  Widget build(BuildContext context) {
    _getInitialInfo();
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
          _myLibrary()
        ],
      )
    );
  }

  Container _myLibrary() {
    return Container(
        height: MediaQuery.of(context).size.height - 213,
        decoration: BoxDecoration(
            // color: Colors.red[400],
            borderRadius: BorderRadius.circular(10)),
        child: 
        Column(children: [
          if (images.isEmpty)
            const Center(
              child: Text("Share your moment",
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),)
            )
          else
          Container(
              height: MediaQuery.of(context).size.height - 213,
              decoration: BoxDecoration(
                  // color: Colors.green[100],
                  borderRadius: BorderRadius.circular(10)),
                  child: ListView.builder(
            itemCount: _imageLength(),
            itemBuilder: (context, index) {
              // final item = users[index] as Map;
              int itemNumber = _itemNumber(index);
              int idxRow1 = itemNumber;
              int idxRow2 = itemNumber + 1;
              int idxRow3 = itemNumber + 2;
              return SizedBox(
                height: 132,
                child: Row(
                  children: [
                    SizedBox(
                      height: 130,
                      width: (MediaQuery.of(context).size.width  / 3) - 1,
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
                      width: (MediaQuery.of(context).size.width  / 3) - 1,
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
                      width: (MediaQuery.of(context).size.width  / 3) - 1,
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
        ),)
      ],)
    );
  }

  int _itemNumber(index){
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

  int _imageLength() {
    int imagesLength = images.length;
    print("images length: $imagesLength");
    var lastImage = images[imagesLength -1];
    print("image: $lastImage");
    var row = imagesLength / 3;
    return row.ceil();
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
