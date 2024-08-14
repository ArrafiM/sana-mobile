// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
// import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:sana_mobile/models/detected_location.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:sana_mobile/shared/circle_loop.dart';
import 'package:sana_mobile/shared/my_position.dart';
import 'package:geolocator/geolocator.dart';
// import 'package:geolocator/geolocator.dart';

// import 'package:sliding_up_panel/sliding_up_panel.dart';
// import 'package:url_launcher/url_launcher.dart';

class SanaScreen extends StatefulWidget {
  const SanaScreen({super.key});

  @override
  State<SanaScreen> createState() => _SanaScreenState();
}

class _SanaScreenState extends State<SanaScreen> {
  double circleWidth = 0;
  double circleOpacity = 1;

  List<LocationModel> locations = [];

  BorderRadiusGeometry radius = const BorderRadius.only(
    topLeft: Radius.circular(24.0),
    topRight: Radius.circular(24.0),
  );

  final LocationSettings locationSettings = const LocationSettings(
    accuracy: LocationAccuracy.high,
    distanceFilter: 100,
    );
  

  void _getData() {
    locations = LocationModel.getlocations();
  }

  @override
  Widget build(BuildContext context) {
    
    _getData();
    return Scaffold(
      appBar: _homeAppBar(context),
      // body: _contentData(context),
      body: _mapView(),
      floatingActionButton: Column(
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width,
            height: 350,
          )
        ],
      ),
      // body: DraggableScrollableSheet(
      //     builder: (BuildContext context, ScrollController scrollController) {
      //   return Container(
      //       color: Colors.blue[100],
      //       child: ListView.builder(
      //           controller: scrollController,
      //           itemCount: 25,
      //           itemBuilder: (BuildContext context, int index) {
      //             return ListTile(title: Text('item ${index + 1}'));
      //           }));
      // }),
      // body: SlidingUpPanel(
      //   panel: _nearestLocations(),
      //   collapsed: Container(
      //     decoration:
      //         BoxDecoration(color: Colors.blueGrey, borderRadius: radius),
      //     child: const Center(
      //       child: Text(
      //         "Nearest locations",
      //         style: TextStyle(color: Colors.white),
      //       ),
      //     ),
      //   ),
      //   body: _contentData(context),
      //   borderRadius: radius,
      // ),
    );
  }

  Column _contentData(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 10,
        ),
        // _mapView(),
        // Center(
        //   child: _radar(context),
        // ),
        SizedBox(
          height: 5,
        ),
        // _nearestLocations(),
      ],
    );
  }

  Column _nearestLocations() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 10, top: 10),
          child: Text(
            'Terdekat',
            style: TextStyle(
                color: Colors.black, fontSize: 18, fontWeight: FontWeight.w600),
          ),
        ),
        const SizedBox(
          height: 5,
        ),
        SizedBox(height: 245, child: _locations())
      ],
    );
  }

  Container _radar(BuildContext context) {
    return Container(
        width: MediaQuery.of(context).size.width,
        height: 350,
        decoration:
            BoxDecoration(color: Colors.blue[100], shape: BoxShape.circle),
        child: const Stack(
          alignment: Alignment.center,
          children: [
            Center(
              child: CircleLoop(time: 3),
            ),
            Center(
              child: MyPosition(),
            ),
            // _floatingButton(context)
          ],
        ));
  }

  // Stack _floatingButton(BuildContext context) {
  //   return Stack(children: <Widget>[
  //     // _searchField(),
  //     Padding(
  //       padding: const EdgeInsets.only(right: 10),
  //       child: Align(
  //         alignment: Alignment.bottomRight,
  //         child: FloatingActionButton(
  //           onPressed: () {
  //             Navigator.of(context).push(
  //               MaterialPageRoute(
  //                 builder: (context) => const ChatScreen(),
  //               ),
  //             );
  //           },
  //           backgroundColor: Colors.blue[200],
  //           child: const Icon(Icons.chat_rounded),
  //         ),
  //       ),
  //     ),
  //   ]);
  // }

  void showModalSheet(BuildContext context) {
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
            ],
          ),
        );
      },
    );
  }

  FlutterMap _mapView() {
    double lat = 37.4219983;
    double long = -122.084;
    Geolocator.getPositionStream(locationSettings: locationSettings).listen(
    (Position? position) {
        print(position == null ? 'Unknown' : '${position.latitude.toString()}, ${position.longitude.toString()}');
    });
    // lat = position!.latitude;
    // long = position.longitude;
    return FlutterMap(
      options: MapOptions(
        initialCenter: LatLng(lat, long),
        initialZoom: 18,
        minZoom: 0,
        maxZoom: 25,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.example.app',
        ),
        // CurrentLocationLayer(),
        // RichAttributionWidget(
        //   attributions: [
        //     TextSourceAttribution(
        //       'OpenStreetMap contributors',
        //       onTap: () => print("tap map"),
        //     ),
        //   ],
        // ),
        CurrentLocationLayer(
          style:  LocationMarkerStyle(
            marker:  const DefaultLocationMarker(
              color: Colors.blue,
              // child: Icon(
              //   Icons.person,
              //   color: Colors.white,
              // ),
            ),
            markerSize:  const Size.square(30),
            accuracyCircleColor: Colors.blue.withOpacity(0.1),
            headingSectorColor: Colors.blue.withOpacity(0.5),
            headingSectorRadius: 100,
          ),
          moveAnimationDuration: Duration.zero, // disable animation
        ),
      ],
    );
  }

  AppBar _homeAppBar(context) {
    return AppBar(
      title: const Text(
        "SANA",
        style: TextStyle(fontWeight: FontWeight.w800),
      ),
      actions: [
        GestureDetector(
          onTap: () {
            showModalSheet(context);
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
    );
  }

  ListView _locations() {
    return ListView.separated(
      itemCount: locations.length,
      shrinkWrap: true,
      scrollDirection: Axis.vertical,
      separatorBuilder: (context, index) => const SizedBox(
        height: 10,
      ),
      padding: const EdgeInsets.only(left: 10, right: 10),
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () {
            print('name : ${locations[index].name}');
          },
          child: Container(
            height: 80,
            padding: const EdgeInsets.only(left: 5),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              // borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                        padding:
                            const EdgeInsets.only(left: 5, right: 5, top: 5),
                        child: Text(
                          '${index + 1}',
                          style: const TextStyle(
                              fontWeight: FontWeight.w500,
                              color: Colors.black,
                              fontSize: 16),
                        )),
                  ],
                ),
                Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: CircleAvatar(
                      backgroundImage: AssetImage(locations[index].photo),
                      radius: 35,
                    )),
                const SizedBox(
                  width: 10,
                ),
                Container(
                  width: 260,
                  padding: const EdgeInsets.only(right: 5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            locations[index].name,
                            style: const TextStyle(
                                fontWeight: FontWeight.w500,
                                color: Colors.black,
                                fontSize: 16),
                          ),
                          const Text(
                            'Location: ',
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: () {
                          print('Message to: ${locations[index].name}');
                        },
                        child: SizedBox(
                          height: 60,
                          width: 60,
                          child: Icon(
                            Icons.chat_bubble,
                            size: 30,
                            color: Colors.grey[500],
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
