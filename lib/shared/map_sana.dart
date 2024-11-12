import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:sana_mobile/screen/detail_point.dart';
// import 'package:sana_mobile/screen/chat_screen.dart';
import 'package:sana_mobile/screen/list_point.dart';
import 'package:sana_mobile/services/location_services.dart';
import 'package:sana_mobile/services/user_services.dart';
import 'package:sana_mobile/shared/logout.dart';

class MapSana extends StatefulWidget {
  const MapSana({Key? key, required this.lat, required this.long})
      : super(key: key);
  final double lat;
  final double long;
  // final List<dynamic> pinData;

  @override
  State<MapSana> createState() => _MapSanaState();
}

class _MapSanaState extends State<MapSana> {
  late AlignOnUpdate _alignPositionOnUpdate;
  late final StreamController<double?> _alignPositionStreamController;

  double lat = 0.0;
  double long = 0.0;

  List<dynamic> pinData = [];

  bool isShow = false;
  int indexShow = -1;
  Map merchant = {};

  String publicApiUrl = "";

  // Function to convert hex color to Flutter's Color object
  Color _hexToColor(String hex) {
    hex = hex.replaceAll('#', '');
    return Color(int.parse('FF$hex', radix: 16));
  }

  @override
  void initState() {
    super.initState();
    _alignPositionOnUpdate = AlignOnUpdate.always;
    _alignPositionStreamController = StreamController<double?>();

    setState(() {
      lat = widget.lat;
      long = widget.long;
      String apiUrl = UserServices.apiUrl();
      publicApiUrl = "$apiUrl/public/";
      // pinData = widget.pinData;
    });

    _fetchNearestLocations(lat, long);
  }

  @override
  void dispose() {
    _alignPositionStreamController.close();
    super.dispose();
  }

  void _refreshPage() {
    _getCurrentLocation();
  }

  @override
  Widget build(BuildContext context) {
    // if (pinData.isEmpty) {
    //   return const Center(
    //     child: CircularProgressIndicator(),
    //   );
    // } else {
    //   return flutterMap(context);
    // }
    return flutterMap(context);
  }

  FlutterMap flutterMap(BuildContext context) {
    return FlutterMap(
      options: MapOptions(
        initialCenter: LatLng(lat, long),
        initialZoom: 18,
        minZoom: 0,
        maxZoom: 50,
        onPositionChanged: (MapCamera camera, bool hasGesture) {
          if (hasGesture && _alignPositionOnUpdate != AlignOnUpdate.never) {
            setState(
              () => _alignPositionOnUpdate = AlignOnUpdate.never,
            );
          }
        },
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.example.app',
        ),
        CurrentLocationLayer(
          style: LocationMarkerStyle(
            marker: const DefaultLocationMarker(
              color: Colors.blue,
              // child: Icon(
              //   Icons.person,
              //   color: Colors.white,
              // ),
            ),
            markerSize: const Size.square(30),
            accuracyCircleColor: Colors.blue.withOpacity(0.1),
            headingSectorColor: Colors.blue.withOpacity(0.5),
            headingSectorRadius: 100,
          ),
          moveAnimationDuration: Duration.zero, // disable animation
          alignPositionStream: _alignPositionStreamController.stream,
          alignPositionOnUpdate: _alignPositionOnUpdate,
        ),
        pinData.isNotEmpty
            ? markerPoint(context)
            : Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16.0),
                margin: const EdgeInsets.only(bottom: 16.0),
                decoration: const BoxDecoration(
                  color: Colors.lightBlueAccent, // Warna biru muda
                  borderRadius: BorderRadius.only(
                    bottomLeft:
                        Radius.circular(30.0), // Pojok kiri bawah melengkung
                    bottomRight:
                        Radius.circular(30.0), // Pojok kanan bawah melengkung
                  ),
                ),
                child: const Text(
                  'No Merchant found, tap circle arrow button to refresh data!',
                  style: TextStyle(
                    fontSize: 16.0,
                    color: Colors.white, // Warna teks putih
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
        // : const Text('No Merchant found, still loaded...'),
        Align(
          alignment: Alignment.bottomRight,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: FloatingActionButton(
              backgroundColor: Colors.blue,
              heroTag: "currentLocation",
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50)),
              onPressed: () {
                // Align the location marker to the center of the map widget
                // on location update until user interact with the map.
                setState(
                  () => _alignPositionOnUpdate = AlignOnUpdate.always,
                );
                // Align the location marker to the center of the map widget
                // and zoom the map to level 18.
                _alignPositionStreamController.add(18);
              },
              child: const Icon(
                Icons.my_location,
                color: Colors.white,
              ),
            ),
          ),
        ),
        Stack(children: <Widget>[
          // _searchField(),
          // pointList(context),
          merchant.isNotEmpty
              ? popUpPointTitle(context)
              : const SizedBox.shrink(),
          showHide(),
          refreshButton(),
        ])
      ],
    );
  }

  Align popUpPointTitle(BuildContext context) {
    return Align(
        alignment: Alignment.bottomLeft,
        child: Padding(
            padding: const EdgeInsets.only(left: 10, bottom: 10),
            child: Container(
              height: 60,
              width: 250,
              decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(15)),
              child: Padding(
                  padding: const EdgeInsets.only(left: 5),
                  child: Row(
                      // crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        merchant['picture'] == ""
                            ? const Padding(
                                padding: EdgeInsets.only(left: 10),
                                child: CircleAvatar(
                                    radius: 25,
                                    child: Icon(Icons.storefront_outlined)))
                            : Padding(
                                padding: const EdgeInsets.only(left: 10),
                                child: CircleAvatar(
                                  backgroundImage: NetworkImage(
                                      publicApiUrl + merchant['picture']),
                                  radius: 25,
                                )),
                        Padding(
                            padding: const EdgeInsets.only(left: 10),
                            child: SizedBox(
                              // decoration: const BoxDecoration(
                              //     color: Colors.grey),
                              width: 120,
                              child: Text(
                                merchant['name'],
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            )),
                        SizedBox(
                          width: 40,
                          height: 40,
                          child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => DetailPoint(
                                          point: pinData[indexShow])),
                                );
                              },
                              child: const Icon(
                                Icons.keyboard_arrow_up_outlined,
                                color: Colors.black,
                                size: 40,
                              )),
                        )
                      ])),
            )));
  }

  Padding pointList(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 20, bottom: 20),
      child: Align(
        alignment: Alignment.bottomLeft,
        child: FloatingActionButton(
          heroTag: "pointList",
          onPressed: () {
            // print("klik list map");
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ListPoint(
                  lat: lat,
                  long: long,
                ),
              ),
            );
          },
          backgroundColor: Colors.grey[600],
          child: const Icon(Icons.view_list, color: Colors.white),
        ),
      ),
    );
  }

  MarkerLayer markerPoint(BuildContext context) {
    return MarkerLayer(
      markers: List.generate(pinData.length, (index) {
        return Marker(
            point: LatLng(
              pinData[index]['latitude'],
              pinData[index]['longitude'],
            ),
            width: 80,
            height: 50,
            rotate: true,
            child: GestureDetector(
              onTap: () {
                popUpPoint(index);

                // showModalSheet(context, pinData[index]['title']);
              },
              child: Stack(
                alignment: Alignment.center,
                children: [
                  isShow
                      ? merchantNamePoint(index)
                      : indexShow == index
                          ? merchantPopPoint(index)
                          : const SizedBox.shrink(),
                  Positioned(
                    top: 5,
                    bottom: 0,
                    child: Icon(
                      Icons.location_on,
                      color: pinData[index]['merchant']['color'] == ""
                          ? _hexToColor('#8a2c2c')
                          : _hexToColor(pinData[index]['merchant']['color']),
                      size: 30,
                    ),
                  ),
                ],
              ),
            ));
      }),
    );
  }

  Positioned merchantNamePoint(int index) {
    return Positioned(
        top: 0,
        child: Container(
            width: 80,
            decoration: BoxDecoration(
                color: Colors.blueGrey[100],
                borderRadius: BorderRadius.circular(15)),
            child: Center(
              child: Text(
                pinData[index]['merchant']['name'],
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            )));
  }

  Positioned merchantPopPoint(int index) {
    return Positioned(
        top: 0,
        child: Container(
            width: 80,
            // height: 50,
            decoration: BoxDecoration(
                color: Colors.blueGrey[100],
                borderRadius: BorderRadius.circular(15)),
            child: Center(
              child: Text(
                pinData[index]['merchant']['name'],
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            )));
  }

  Padding refreshButton() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 100, right: 20),
      child: Align(
        alignment: Alignment.bottomRight,
        child: FloatingActionButton(
          heroTag: "refreshbutton",
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
          onPressed: () {
            print("refresh map");
            _refreshPage();
          },
          backgroundColor: Colors.blue,
          child: const Icon(Icons.refresh, color: Colors.white),
        ),
      ),
    );
  }

  Padding showHide() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 180, right: 20),
      child: Align(
        alignment: Alignment.bottomRight,
        child: FloatingActionButton(
            heroTag: "showHide",
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
            onPressed: () {
              print('hideshow');
              updateShowHide();
            },
            backgroundColor: Colors.blue,
            child: isShow
                ? const Icon(Icons.visibility_off_outlined, color: Colors.white)
                : const Icon(Icons.visibility_outlined, color: Colors.white)),
      ),
    );
  }

  void popUpPoint(index) {
    setState(() {
      if (index == indexShow) {
        indexShow = -1;
        merchant = {};
      } else {
        indexShow = index;
        merchant = pinData[index]['merchant'];
      }
    });
    print(merchant['name']);
  }

  void updateShowHide() {
    setState(() {
      if (isShow == false) {
        isShow = true;
      } else {
        isShow = false;
      }
    });
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

  Future<void> _fetchNearestLocations(lat, long) async {
    final response = await LocationServices.fetchNearestLocations(
        lat, long, 2000, 1, 1000, null, null);
    if (response != null) {
      if (response == 401) {
        print("Unauthorized 401");
        showLogoutDialog(context);
      } else {
        print("fetch location");
        if (mounted) {
          setState(() {
            pinData = response['data'];
          });
        }
      }
    } else {
      const SnackBar(content: Text("Something went Wrong"));
    }
  }
}
