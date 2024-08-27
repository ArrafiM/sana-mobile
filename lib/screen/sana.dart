import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sana_mobile/models/detected_location.dart';
import 'package:sana_mobile/services/location_services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:sana_mobile/shared/logout.dart';
// import 'package:sana_mobile/shared/logout.dart';
import 'package:sana_mobile/shared/map_sana.dart';
import 'package:sana_mobile/shared/map_topbar.dart';

class SanaScreen extends StatefulWidget {
  const SanaScreen({super.key});

  @override
  State<SanaScreen> createState() => _SanaScreenState();
}

class _SanaScreenState extends State<SanaScreen> with WidgetsBindingObserver {
  Map<String, dynamic> myLocation = {};
  int statusCode = 200;

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
    if (lat != 0.0 || long != 0.0) _fetchNearestLocations(lat, long);
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
      if (lat != 0.0 || long != 0.0) _fetchNearestLocations(lat, long);
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
      print('latitude: $lat, longitude: $long ');

      if (mounted) {
        setState(() {
          lat = position.latitude;
          long = position.longitude;
        });
      }

      if (lat != 0.0 || long != 0.0) _fetchNearestLocations(lat, long);
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
          : (statusCode == 401)
              ? Padding(
                  padding: const EdgeInsets.only(top: 50),
                  child: Center(
                      child: Column(
                    children: [
                      const Text("Session Expired!"),
                      const Text("please login again!"),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pushNamedAndRemoveUntil(
                            context,
                            '/login', // Replace '/login' with the route name for your login screen
                            (route) => false,
                          );
                        },
                        child: const Text('Login'),
                      ),
                    ],
                  )),
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
    );
  }

  Future<void> _fetchNearestLocations(lat, long) async {
    final response = await LocationServices.fetchNearestLocations(lat, long);
    if (response != null) {
      if (response == 401) {
        print("Unauthorized 401");
        showLogoutDialog(context);
        if (mounted) {
          setState(() {
            statusCode = 401;
          });
        }
      } else {
        print("fetch location: ${response['data']}");
        if (mounted) {
          setState(() {
            pinData = response['data'];
          });
        }
      }
      print("pin data: $pinData");
    } else {
      const SnackBar(content: Text("Something went Wrong"));
    }
  }
}
