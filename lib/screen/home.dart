// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sana_mobile/models/category_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<CategoryModel> categories = [];
  bool isDarkMode = false;
  Color bgColor = Colors.white;
  Color systemFontColor = const Color.fromARGB(255, 255, 255, 255);

  void _getInitialInfo() {
    categories = CategoryModel.getCategories();
  }

  void _cekThemeColor(context) {
    var brightness = MediaQuery.of(context).platformBrightness;
    isDarkMode = brightness == Brightness.dark;
    bgColor = isDarkMode ? Colors.black : Colors.white;
    systemFontColor = isDarkMode ? Colors.white : Colors.black;
  }

  @override
  Widget build(BuildContext context) {
    _getInitialInfo();
    _cekThemeColor(context);
    return Scaffold(
        appBar: AppBar(
          toolbarHeight: 0,
        ),
        body: NestedScrollView(
            headerSliverBuilder:
                (BuildContext context, bool innerBoxIsScrolled) {
              return <Widget>[_homeAppBar(context)];
            },
            body: _listViewContent()));
  }

  ListView _listViewContent() {
    return ListView.builder(
      itemCount: categories.length,
      padding: const EdgeInsets.only(top: 0),
      itemBuilder: (context, index) {
        if (index == 0) {
          return Column(children: [
            _status(),
            _contentData(index),
          ]);
        } else {
          return _contentData(index);
        }
      },
    );
  }

  Container _contentData(index) {
    return Container(
        height: 400,
        width: MediaQuery.of(context).size.width,
        decoration: const BoxDecoration(color: Colors.white),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onDoubleTap: () {
                print(
                    "like this double tap, ${categories[index].name}, ${index + 1}");
              },
              child: Container(
                height: 320,
                width: MediaQuery.of(context).size.width,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  // border: Border.all()
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SvgPicture.asset(categories[index].iconPath),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.only(left: 10, right: 10, top: 5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(
                        Icons.message_outlined,
                        color: Colors.black,
                      ),
                      Icon(
                        Icons.ios_share_outlined,
                        color: Colors.black,
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          print(
                              "Like this content: ${categories[index].name}, ${index + 1}");
                        },
                        child: const Icon(
                          Icons.favorite_border,
                          color: Colors.black,
                        ),
                      )
                    ],
                  )
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.only(left: 10, right: 10, top: 5),
              child: Text(
                categories[index].name,
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    fontSize: 16),
              ),
            ),
          ],
        ));
  }

  Container _status() {
    return Container(
      height: 110,
      decoration: const BoxDecoration(color: Colors.white),
      child: ListView.separated(
        itemCount: categories.length,
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.only(left: 20, right: 20),
        separatorBuilder: (context, index) => const SizedBox(
          width: 10,
        ),
        itemBuilder: (context, index) {
          return Column(
            children: [
              GestureDetector(
                onTap: () {
                  print('touched photo : ${categories[index].name}');
                },
                child: Container(
                  width: 85,
                  height: 85,
                  decoration: BoxDecoration(
                      color: categories[index].boxColor.withOpacity(0.3),
                      shape: BoxShape.circle
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
                          child: SvgPicture.asset(categories[index].iconPath),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Text(
                categories[index].name,
                style: const TextStyle(
                    fontWeight: FontWeight.w400,
                    color: Colors.black,
                    fontSize: 14),
              ),
            ],
          );
        },
      ),
    );
  }

  SliverOverlapAbsorber _homeAppBar(context) {
    return SliverOverlapAbsorber(
      handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
      sliver: SliverAppBar(
        title: const Text(
          "SANA",
          style: TextStyle(
            fontWeight: FontWeight.w800,
            color: Colors.black,
          ),
        ),
        floating: true,
        pinned: false,
        snap: true,
        // shadowColor: Colors.amber[600],
        backgroundColor: Colors.white,
        actions: [
          GestureDetector(
            onTap: () {
              print("notif");
            },
            child: Container(
                margin: const EdgeInsets.all(10),
                alignment: Alignment.center,
                width: 30,
                decoration: BoxDecoration(
                    // color: const Color(0xffF7F8F8),
                    borderRadius: BorderRadius.circular(10)),
                child: const Icon(
                  Icons.notifications,
                  color: Colors.black,
                )),
          ),
          GestureDetector(
            onTap: () {
              print("More");
            },
            child: Container(
              decoration: BoxDecoration(
                  // color: Colors.blue[100],
                  borderRadius: BorderRadius.circular(10)),
              alignment: Alignment.center,
              margin: const EdgeInsets.all(10),
              width: 40,
              child: const Icon(Icons.more_horiz_rounded),
            ),
          )
        ],
      ),
    );
  }
}
