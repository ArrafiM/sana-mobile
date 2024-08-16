import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:latlong2/latlong.dart';
import 'package:sana_mobile/screen/detail_point.dart';
// import 'package:sana_mobile/screen/chat_screen.dart';
import 'package:sana_mobile/screen/list_point.dart';

class MapSana extends StatefulWidget {
  const MapSana(
      {Key? key, required this.lat, required this.long, required this.pinData})
      : super(key: key);
  final double lat;
  final double long;
  final List<dynamic> pinData;

  @override
  State<MapSana> createState() => _MapSanaState();
}

class _MapSanaState extends State<MapSana> {
  late AlignOnUpdate _alignPositionOnUpdate;
  late final StreamController<double?> _alignPositionStreamController;

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
  }

  @override
  void dispose() {
    _alignPositionStreamController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      options: MapOptions(
        initialCenter: LatLng(widget.lat, widget.long),
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
        MarkerLayer(
          markers: List.generate(widget.pinData.length, (index) {
            return Marker(
                point: LatLng(
                  widget.pinData[index]['latitude'],
                  widget.pinData[index]['longitude'],
                ),
                width: 80,
                height: 50,
                rotate: true,
                child: GestureDetector(
                  onTap: () {
                    // print("Tap on: ${widget.pinData[index]['title']}");
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              DetailPoint(point: widget.pinData[index])),
                    );
                    // showModalSheet(context, widget.pinData[index]['title']);
                  },
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Positioned(
                        top: 0,
                        child: Text(
                          widget.pinData[index]['title'],
                          style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      Positioned(
                        top: 5,
                        bottom: 0,
                        child: Icon(
                          Icons.location_on,
                          color: _hexToColor(widget.pinData[index]['color']),
                          size: 30,
                        ),
                      ),
                    ],
                  ),
                ));
          }),
        ),
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
          Padding(
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
                        point: widget.pinData,
                      ),
                    ),
                  );
                  // Navigator.of(context).push(
                  //   MaterialPageRoute(
                  //     builder: (context) => const ChatScreen(),
                  //   ),
                  // );
                },
                backgroundColor: Colors.grey[600],
                child: const Icon(Icons.view_list, color: Colors.white),
              ),
            ),
          ),
        ])
      ],
    );
  }
}
