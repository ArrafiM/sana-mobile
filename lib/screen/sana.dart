// ignore_for_file: avoid_print

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sana_mobile/models/detected_location.dart';
import 'package:sana_mobile/services/location_services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:sana_mobile/shared/map_sana.dart';
import 'package:sana_mobile/shared/map_topbar.dart';

// import 'package:sliding_up_panel/sliding_up_panel.dart';
// import 'package:url_launcher/url_launcher.dart';

class SanaScreen extends StatefulWidget {
  const SanaScreen({super.key});

  @override
  State<SanaScreen> createState() => _SanaScreenState();
}

class _SanaScreenState extends State<SanaScreen> with WidgetsBindingObserver {
  Map<String, dynamic> myLocation = {};

  double circleWidth = 0;
  double circleOpacity = 1;

  List<LocationModel> locations = [];
  double lat = 0.0;
  double long = 0.0;

  List<dynamic> pinData = [];

  BorderRadiusGeometry radius = const BorderRadius.only(
    topLeft: Radius.circular(24.0),
    topRight: Radius.circular(24.0),
  );

  final LocationSettings locationSettings = const LocationSettings(
    accuracy: LocationAccuracy.high,
    distanceFilter: 100,
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _getCurrentLocation();
    _fetchNearestLocations();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Get location when the screen is active again
      _getCurrentLocation();
      _fetchNearestLocations();
    }
  }

  Future<void> _getCurrentLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always) {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      print("Location latlong updated!");
      setState(() {
        lat = position.latitude;
        long = position.longitude;
      });
      print('latitude: $lat, longitude: $long ');
    } else {
      // Handle case where permission is denied
      print("Location permission denied");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MapTopbar(),
      body: (lat == 0.0 || long == 0.0)
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : (pinData.isEmpty)
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : MapSana(
                  lat: lat,
                  long: long,
                  pinData: pinData,
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

  // Column _contentData(BuildContext context) {
  //   return const Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       SizedBox(
  //         height: 10,
  //       ),
  //       // _mapView(),
  //       // Center(
  //       //   child: _radar(context),
  //       // ),
  //       SizedBox(
  //         height: 5,
  //       ),
  //       // _nearestLocations(),
  //     ],
  //   );
  // }

  // Column _nearestLocations() {
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       const Padding(
  //         padding: EdgeInsets.only(left: 10, top: 10),
  //         child: Text(
  //           'Terdekat',
  //           style: TextStyle(
  //               color: Colors.black, fontSize: 18, fontWeight: FontWeight.w600),
  //         ),
  //       ),
  //       const SizedBox(
  //         height: 5,
  //       ),
  //       SizedBox(height: 245, child: _locations())
  //     ],
  //   );
  // }

  // Container _radar(BuildContext context) {
  //   return Container(
  //       width: MediaQuery.of(context).size.width,
  //       height: 350,
  //       decoration:
  //           BoxDecoration(color: Colors.blue[100], shape: BoxShape.circle),
  //       child: const Stack(
  //         alignment: Alignment.center,
  //         children: [
  //           Center(
  //             child: CircleLoop(time: 3),
  //           ),
  //           Center(
  //             child: MyPosition(),
  //           ),
  //           // _floatingButton(context)
  //         ],
  //       ));
  // }

  Future<void> _fetchNearestLocations() async {
    final response = await LocationServices.fetchNearestLocations();
    if (response != null) {
      setState(() {
        pinData = response['data'];
        print("fetch location: ${response['data']}");
      });
    } else {
      // const SnackBar(content: Text("Something went Wrong"));
    }
  }
}
