import 'package:flutter/material.dart';
import 'package:sana_mobile/screen/detail_point.dart';
import 'package:sana_mobile/services/helper_services.dart';
import 'package:sana_mobile/services/location_services.dart';
import 'package:sana_mobile/services/user_services.dart';
import 'package:sana_mobile/shared/logout.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({Key? key}) : super(key: key);

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  late ScrollController _scrollController;
  final TextEditingController _searchController = TextEditingController();
  String publicApiUrl = "";
  List merchantData = [];
  bool _isLoading = false;
  bool _isRefresh = false;
  int _page = 1;
  final int _pageSize = 10;
  final int _radius = 2000;
  int merchants = 10;
  int maxItem = 3;
  String search = "";

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    setState(() {
      String apiUrl = UserServices.apiUrl();
      publicApiUrl = "$apiUrl/public/";
    });
    _getData();
  }

  Future _getData() async {
    String? lat = await UserServices.getLocaData('lat');
    String? long = await UserServices.getLocaData('long');
    _fetchNearestLocations(lat, long, _radius, _page, _pageSize, null);
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
              _scrollController.position.maxScrollExtent &&
          !_isLoading) {
        _fetchNearestLocations(lat, long, _radius, _page, _pageSize, search);
      }
    });
  }

  Future<void> _searchData(value) async {
    String? lat = await UserServices.getLocaData('lat');
    String? long = await UserServices.getLocaData('long');
    setState(() {
      _page = 1;
    });
    await _fetchNearestLocations(lat, long, _radius, 1, _pageSize, value);
  }

  Future<void> _refreshData() async {
    setState(() {
      _isRefresh = true;
    });
    await _searchData("");
    setState(() {
      _isRefresh = false;
    });
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
          title: Row(
            children: [
              // Search Field
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: "Search...",
                    fillColor: const Color.fromARGB(255, 237, 236, 236),
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(30), // Sudut melengkung
                      borderSide: BorderSide.none, // Hilangkan garis pinggir
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 20),
                    // prefixIcon: const Icon(Icons.search),
                  ),
                  onSubmitted: (value) {
                    if (value == "") {
                      _refreshData();
                    } else {
                      _searchData(value);
                    }

                    FocusScope.of(context).unfocus();
                  },
                ),
              ),
              // Icon Search
              IconButton(
                icon: const Icon(Icons.search),
                onPressed: () {
                  String value = _searchController.text;
                  if (value == "") {
                    _refreshData();
                  } else {
                    _searchData(value);
                  }
                  FocusScope.of(context).unfocus();
                },
              ),
            ],
          ),
        ),
        body: RefreshIndicator(
          onRefresh: _refreshData,
          child: merchantData.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Sorry, no merchant found in your location"),
                      const SizedBox(height: 10),
                      GestureDetector(
                        onTap: () {
                          _refreshData();
                        },
                        child: const Text(
                          "Refresh",
                          style: TextStyle(color: Colors.blue),
                        ),
                      )
                    ],
                  ),
                )
              : ListView.builder(
                  controller: _scrollController,
                  itemCount: merchantData.length,
                  itemBuilder: (context, index) {
                    List items = merchantData[index]['merchant']['merchandise'];
                    if (index == 0) {
                      return Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              items.isNotEmpty
                                  ? _merchantClick(index)
                                  : const SizedBox.shrink(),
                              itemList(index),
                              Divider(color: Colors.grey[300]),
                            ],
                          ));
                    } else {
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          items.isNotEmpty
                              ? _merchantClick(index)
                              : const SizedBox.shrink(),
                          itemList(index),
                          Divider(color: Colors.grey[300]),
                        ],
                      );
                    }
                  }),
        ));
  }

  GestureDetector _merchantClick(index) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => DetailPoint(point: merchantData[index])),
        );
      },
      child: merchantList(index),
    );
  }

  SizedBox merchantList(index) {
    return SizedBox(
      height: 70,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Row(children: [
              merchantData[index]['merchant']['picture'] == ""
                  ? const Padding(
                      padding: EdgeInsets.only(left: 10),
                      child: CircleAvatar(
                          radius: 30, child: Icon(Icons.storefront_outlined)))
                  : Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: CircleAvatar(
                        backgroundImage: NetworkImage(publicApiUrl +
                            merchantData[index]['merchant']['picture']),
                        radius: 30,
                      )),
              Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: Text(merchantData[index]['merchant']['name'])),
            ]),
            Padding(
                padding: const EdgeInsets.only(right: 10),
                child: Text(
                    "<${merchantData[index]['distance'].toStringAsFixed(1)} km"))
          ]),
          // const SizedBox(height: 5), // Beri jarak antar avatar dan list
          // itemList(index)
        ],
      ),
    );
  }

  SizedBox itemList(int idx) {
    List itemData = merchantData[idx]['merchant']['merchandise'];
    if (itemData.isNotEmpty) {
      double hg = 180;
      if (itemData.length == 1) hg = 110;
      return SizedBox(
          height: hg, // Set height for the entire widget, including ListView
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                  padding: const EdgeInsets.only(left: 10, bottom: 5),
                  child: SizedBox(
                    height: 100,
                    child: rowData(itemData, 0, true),
                  )),
              itemData.length > 1
                  ? Column(children: [
                      // Padding(
                      //     padding: const EdgeInsets.only(left: 10),
                      //     child: Divider(color: Colors.grey[300])),
                      SizedBox(
                        height: 50, // Height specifically for the ListView
                        child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.only(left: 10, right: 20),
                            separatorBuilder: (context, index) =>
                                const SizedBox(
                                  width: 10,
                                ),
                            itemCount: itemData.length,
                            itemBuilder: (context, index) {
                              if (index + 1 == itemData.length) {
                                return const SizedBox.shrink();
                              } else {
                                return rowData(itemData, index + 1, false);
                              }
                            }),
                      )
                    ])
                  : const SizedBox.shrink()
            ],
          ));
    } else {
      return const SizedBox.shrink();
    }
  }

  Row rowData(List<dynamic> itemData, int index, bool isMain) {
    double size = 50;
    if (isMain) size = 100;
    List<dynamic> items = itemData[index]["tag"] ?? [];
    List<String> stringItems = items.map((item) => item.toString()).toList();
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      itemData[index]['picture'] == ""
          ? Container(
              height: size,
              width: size,
              decoration: BoxDecoration(
                  color: Colors.grey, borderRadius: BorderRadius.circular(10)))
          : Container(
              height: size,
              width: size,
              decoration: BoxDecoration(
                  color: Colors.grey,
                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                  image: DecorationImage(
                      image: NetworkImage(
                          publicApiUrl + itemData[index]['picture']),
                      fit: BoxFit.cover)),
            ),
      isMain == true
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              // mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                    width: 160,
                    child: Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: Text(
                          "${itemData[index]['name']}",
                          style: const TextStyle(
                            fontSize: 14,
                            // fontWeight: FontWeight.bold
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ))),
                Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: SizedBox(
                      height: 60, // Atur tinggi kotak scroll
                      // decoration:
                      //     BoxDecoration(border: Border.all(color: Colors.grey)),
                      width: MediaQuery.of(context).size.width - 140,
                      child: SingleChildScrollView(
                        child: Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: Wrap(
                              spacing: 5.0, // Jarak horizontal antar kotak
                              runSpacing: 2.0, // Jarak vertikal antar kotak
                              children: stringItems
                                  .map<Widget>((tag) => Container(
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(5),
                                          border: Border.all(
                                              color: Colors.blueAccent),
                                        ),
                                        child: Text(
                                            tag), // Gunakan tag untuk menampilkan teks
                                      ))
                                  .toList(), // Konversi ke List<Widget>
                            )),
                      ),
                    )),
                Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: Text(
                      HelperServices.formatCurrency(
                          itemData[index]['price'].toDouble()),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ))
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                    width: 80,
                    child: Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: Text(
                          "${itemData[index]['name']}",
                          style: const TextStyle(
                            fontSize: 14,
                            // fontWeight: FontWeight.bold
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ))),
              ],
            )
    ]);
  }

  Future<void> _fetchNearestLocations(
      lat, long, radius, page, pageSize, search) async {
    print("page: $page");
    setState(() {
      _isLoading = true;
    });
    final response = await LocationServices.fetchNearestLocations(
        lat, long, radius, page, pageSize, search, true);
    if (response != null) {
      if (response == 401) {
        print("Unauthorized 401");
        showLogoutDialog(context);
      } else {
        if (mounted) {
          List resData = response['data'];
          print("fetch location list: ${resData.length}");
          if (resData.isNotEmpty) {
            setState(() {
              if ((page == 1 && search != "") || _isRefresh) {
                merchantData = resData;
              } else {
                merchantData.addAll(resData);
              }
              _page++;
            });
          }
          setState(() {
            _isLoading = false;
          });
        }
      }
    } else {
      const SnackBar(content: Text("Something went Wrong"));
    }
  }
}
