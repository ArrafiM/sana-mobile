import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:sana_mobile/models/detected_location.dart';
import 'package:geolocator/geolocator.dart';
// import 'package:sana_mobile/services/location_services.dart';
import 'package:sana_mobile/services/socket_services.dart';
import 'package:sana_mobile/services/user_services.dart';
// import 'package:sana_mobile/shared/logout.dart';
import 'package:sana_mobile/shared/map_sana.dart';
import 'package:sana_mobile/shared/map_topbar.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  final SocketService _socketService =
      SocketService(); // Initialize the socket service
  // late StreamSubscription<String> _messageSubscription;

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
    _webSocketConnect();
    _getCurrentLocation();
    _storeFcmToken();
  }

  Future<void> _webSocketConnect() async {
    // Connect to the WebSocket server
    // String? userId = await UserServices.checkMyId();
    String wsUrl = await UserServices.wsUrl();
    _socketService.connect(wsUrl);
    // Listen for messages from the WebSocket
    // _messageSubscription = _socketService.messageStream.listen((message) async {
    //   // Handle incoming messages
    //   print("Received message: $message");
    //   if (message == 'postMyLocationuser$userId') {
    //     // _socketService.postLocation(userId, lat, long);
    //     bool response = await LocationServices.getNewLatlong(lat, long);
    //     if (response) {
    //       _socketService.triggerPostLocation(userId);
    //     }
    //   }
    // });
  }

  @override
  void dispose() {
    // _messageSubscription.cancel(); // Cancel the subscription
    // _socketService.disconnect(); // Disconnect the WebSocket
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      // Disconnect WebSocket when the app goes to background or is closed
      _socketService.disconnect();
    } else if (state == AppLifecycleState.resumed) {
      // Reconnect WebSocket when the app resumes
      _getCurrentLocation();
      String wsUrl = await UserServices.wsUrl();
      _socketService.connect(wsUrl);
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
      // _postNewLocation(lat, long);
      //localStorage
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('lat', lat.toString());
      await prefs.setString('long', long.toString());
      // String? userId = await UserServices.checkMyId();
      // _socketService.triggerPostLocation(userId);
    } else {
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
          : MapSana(
              lat: lat,
              long: long,
            ),
    );
  }

  Future<String?> getToken() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    // Mendapatkan registration token
    String? token = await messaging.getToken();
    print("FCM Registration Token: $token");
    return token;
  }

  Future<void> _storeFcmToken() async {
    String? userid = await UserServices.checkMyId();
    String? token = await getToken();
    bool store = await UserServices.storeDevicetoken(userid, token);
    if (store) {
      print('token stored');
    } else {
      print('failed store token');
    }
  }
}
