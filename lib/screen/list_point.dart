import 'package:flutter/material.dart';
import 'package:sana_mobile/screen/detail_point.dart';
import 'package:sana_mobile/services/location_services.dart';
import 'package:sana_mobile/shared/logout.dart';

class ListPoint extends StatefulWidget {
  final double lat;
  final double long;

  const ListPoint({
    Key? key,
    required this.lat,
    required this.long,
  }) : super(key: key);

  @override
  State<ListPoint> createState() => _ListPointState();
}

class _ListPointState extends State<ListPoint> {
  late ScrollController _scrollController;
  String publicApiUrl =
      "https://f37a-2a09-bac5-3a13-18be-00-277-3e.ngrok-free.app/public/";
  List pointData = [];
  bool _isLoading = false;
  int _page = 1;
  final int _pageSize = 10;
  final int _radius = 2000;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _fetchNearestLocations(widget.lat, widget.long, _radius, _page, _pageSize);

    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
              _scrollController.position.maxScrollExtent &&
          !_isLoading) {
        _fetchNearestLocations(
            widget.lat, widget.long, _radius, _page, _pageSize);
      }
    });
  }

  Future<void> _refresh() async {
    _fetchNearestLocations(widget.lat, widget.long, _radius, _page, _pageSize);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'List',
                style: TextStyle(fontSize: 11),
              ),
              Text(
                'Nearest Sana',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          centerTitle: true,
        ),
        body: RefreshIndicator(
          onRefresh: _refresh,
          child: ListView.builder(
            controller: _scrollController,
            itemCount: pointData.length + 1,
            itemBuilder: (context, index) {
              if (index == pointData.length) {
                return _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : const SizedBox.shrink();
              }
              return Padding(
                padding: const EdgeInsets.only(
                    top: 3, bottom: 3), // Sesuaikan jarak sesuai kebutuhan
                child: GestureDetector(
                  onTap: () {
                    print("tap merchant list index: $index");
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              DetailPoint(point: pointData[index])),
                    );
                  },
                  child: _listMerchants(context, index),
                ),
              );
            },
          ),
        ));
  }

  Container _listMerchants(BuildContext context, int index) {
    return Container(
        decoration: BoxDecoration(color: Colors.blue[100]),
        height: 100,
        width: MediaQuery.of(context).size.width,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Container(
                width: 80,
                decoration: BoxDecoration(
                    color: Colors.grey[400],
                    borderRadius: const BorderRadius.all(Radius.circular(20)),
                    image: DecorationImage(
                        image: NetworkImage(publicApiUrl +
                            pointData[index]['merchant']['picture']),
                        fit: BoxFit.cover)),
              ),
            ),
            Padding(
                padding: const EdgeInsets.only(left: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          pointData[index]['merchant']['name'],
                          style: const TextStyle(
                              fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width - 160,
                          child: Text(
                            pointData[index]['merchant']['description'],
                            style: const TextStyle(
                              fontSize: 12,
                            ),
                          ),
                        )
                      ],
                    ),
                    Text(
                        "${pointData[index]['distance'].toStringAsFixed(1)} m"),
                  ],
                )),
          ],
        ));
  }

  Future<void> _fetchNearestLocations(lat, long, radius, page, pageSize) async {
    print("page: $page");
    setState(() {
      _isLoading = true;
    });
    final response = await LocationServices.fetchNearestLocations(
        lat, long, radius, page, pageSize);
    if (response != null) {
      if (response == 401) {
        print("Unauthorized 401");
        showLogoutDialog(context);
      } else {
        print("fetch location: ${response['data']}");
        if (mounted) {
          List resData = response['data'];
          if (resData.isNotEmpty) {
            setState(() {
              pointData.addAll(resData);
              _page++;
            });
          }
          setState(() {
            _isLoading = false;
          });
        }
      }
      print("pin data: $pointData");
    } else {
      const SnackBar(content: Text("Something went Wrong"));
    }
  }
}
