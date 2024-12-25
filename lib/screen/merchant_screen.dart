import 'dart:async';

import 'package:flutter/material.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:sana_mobile/screen/landingimage_merchant.dart';
import 'package:sana_mobile/screen/merchandise_upsert.dart';
import 'package:sana_mobile/screen/merchant_create.dart';
import 'package:sana_mobile/services/merchant_services.dart';
import 'package:sana_mobile/services/socket_services.dart';
import 'package:sana_mobile/services/user_services.dart';
import 'package:sana_mobile/shared/detail_item.dart';
// import 'package:sana_mobile/shared/mymerchant_topbar.dart';
import 'package:sana_mobile/shared/simple_topbar.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';

class MerchantScreen extends StatefulWidget implements PreferredSizeWidget {
  const MerchantScreen({
    Key? key,
  }) : super(key: key);

  @override
  State<MerchantScreen> createState() => _MerchantScreenState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _MerchantScreenState extends State<MerchantScreen> {
  final PageController _pageController = PageController();
  late StreamSubscription<String> _messageSubscription;
  late ScrollController _scrollController;
  Color backgroundColorLanding = Colors.white;
  String publicApiUrl = "";
  Map<String, dynamic> merchant = {};
  List landingImage = [];
  bool isLoad = true;
  String? myId = '';

  List merchandise = [];

  @override
  void initState() {
    super.initState();
    _websocketConnect();
    String apiUrl = UserServices.apiUrl();
    setState(() {
      publicApiUrl = "$apiUrl/public/";
    });
    _scrollController = ScrollController();
    fetchMyMerchant();
  }

  Future<void> _websocketConnect() async {
    String? userId = await UserServices.checkMyId();
    setState(() {
      myId = userId;
    });
    _messageSubscription = SocketService().messageStream.listen((message) {
      print("socket msg mymerchant: $message");
      if (message == "myMerchant$myId") {
        fetchMyMerchant();
      }
    });
  }

  Future<void> _updatePalette() async {
    if (merchant['picture'] != "") {
      final imageProvider =
          CachedNetworkImageProvider("$publicApiUrl${merchant['picture']}");
      final PaletteGenerator paletteGenerator =
          await PaletteGenerator.fromImageProvider(imageProvider);

      setState(() {
        backgroundColorLanding =
            paletteGenerator.dominantColor?.color ?? Colors.white;
      });
    }
  }

  Future<void> _refresh() async {
    fetchMyMerchant();
  }

  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      // Disconnect WebSocket when the app goes to background or is closed
      SocketService().disconnect();
    } else if (state == AppLifecycleState.resumed) {
      fetchMyMerchant();
      // Reconnect WebSocket when the app resumes
      String wsUrl = await UserServices.wsUrl();
      SocketService().connect(wsUrl);
    }
  }

  deleteConfirm(id, name) {
    showDialog(
      context: context,
      // barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Item!'),
          content: Text('Are you sure to delete item [$name]?'),
          backgroundColor: Colors.white,
          actions: [
            TextButton(
              child: const Text(
                'No',
                style: TextStyle(color: Colors.blue),
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            TextButton(
              child: const Text(
                'Yes',
                style: TextStyle(color: Colors.blue),
              ),
              onPressed: () {
                Navigator.pop(context);
                deleteMerchindise(id, name);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _messageSubscription.cancel(); // Cancel the subscription
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: merchant['name'] != ''
            // ? MyMerchantTopbar(merchant: merchant)
            ? merchantAppBar(context)
            : const SimpleTopBar(),
        body: _myMerchantData());
  }

  AppBar merchantAppBar(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      title: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Detail',
            style: TextStyle(fontSize: 12),
          ),
          Text(
            'Merchant',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
        ],
      ),
      centerTitle: true,
      actions: <Widget>[
        merchant.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.settings_outlined),
                onPressed: () {
                  // Aksi saat tombol notifications ditekan
                  showModalSheet(context, null);
                },
              )
            : const SizedBox.shrink()
      ],
    );
  }

  RefreshIndicator _myMerchantData() {
    return RefreshIndicator(
      onRefresh: _refresh,
      child: isLoad
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : merchant.isEmpty
              ? Center(
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                      const Text("Create your merchant"),
                      ElevatedButton(
                          onPressed: () async {
                            print('Create merchant page');
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const MerchantCreate(
                                        name: '',
                                        desc: '',
                                        pathImage: '',
                                        merchantId: 0,
                                      )),
                            );
                            _refresh();
                          },
                          style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: Colors.blue, // Text color
                              minimumSize: const Size(120, 40)),
                          child: const Icon(
                            Icons.add_business_outlined,
                            color: Colors.white,
                          ))
                    ]))
              : ListView.builder(
                  itemCount: merchandise.length,
                  padding: const EdgeInsets.only(top: 0),
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return Column(children: [
                        landingImage.isEmpty
                            ? const SizedBox.shrink()
                            : merchantHeader(),
                        landingImage.isEmpty
                            ? const SizedBox.shrink()
                            : sliderIndicator(),
                        merchantDetail(context),
                        merchandiseTitle(),
                        _merchandiseList(index),
                      ]);
                    } else {
                      return _merchandiseList(index);
                    }
                  },
                ),
    );
  }

  Container sliderIndicator() {
    return Container(
      decoration: const BoxDecoration(color: Colors.white),
      child: Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.only(top: 5),
            child: SmoothPageIndicator(
              controller: _pageController,
              count: landingImage.length,
              effect: const WormEffect(
                dotHeight: 5,
                dotWidth: 5,
                activeDotColor: Colors.blue,
                dotColor: Colors.grey,
              ),
            ),
          )),
    );
  }

  Container merchandiseTitle() {
    return Container(
        decoration: const BoxDecoration(color: Colors.white),
        height: 35,
        child: const Padding(
          padding: EdgeInsets.only(top: 10, left: 10),
          child: Align(
            alignment: Alignment.topLeft,
            child: Text(
              "Item list:",
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ));
  }

  Container merchantHeader() {
    return Container(
        decoration: const BoxDecoration(color: Colors.white),
        height: 200,
        child: (landingImage.isEmpty)
            ? Image.network(
                "https://buffer.com/cdn-cgi/image/w=1000,fit=contain,q=90,f=auto/library/content/images/size/w600/2023/10/free-images.jpg",
                fit: BoxFit.cover,
              )
            : imageSlider());
  }

  Container merchantDetail(BuildContext context) {
    return Container(
        decoration: const BoxDecoration(color: Colors.white),
        height: 120,
        child: Padding(
          padding: const EdgeInsets.only(left: 5, bottom: 20),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            // mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              if (merchant['picture'] != "")
                CircleAvatar(
                  backgroundImage: CachedNetworkImageProvider(
                      publicApiUrl + merchant['picture']),
                  radius: 50,
                )
              else
                const CircleAvatar(
                  backgroundImage: AssetImage("assets/photos/slogo.png"),
                  radius: 50,
                ),
              Padding(
                padding: const EdgeInsets.all(10),
                child: SizedBox(
                  // decoration: BoxDecoration(color: Colors.grey[600]),
                  width: MediaQuery.of(context).size.width - 160,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${merchant['name']}",
                        style: const TextStyle(
                            fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        "${merchant['description']}",
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ));
  }

  Stack imageSlider() {
    return Stack(
      children: [
        PageView.builder(
          controller: _pageController,
          itemCount: landingImage.length,
          itemBuilder: (context, index) {
            return Image.network(
              publicApiUrl + landingImage[index]['url'],
              fit: BoxFit.cover,
              width: double.infinity,
            );
          },
        ),
      ],
    );
  }

  _merchandiseList(index) {
    if (merchandise[index] == '0') {
      return const Padding(
        padding: EdgeInsets.only(top: 10),
        child: Center(
          child: Text("Item: -"),
        ),
      );
    } else {
      List<dynamic> items = merchandise[index]['tag'] ?? [];
      List<String> stringItems = items.map((item) => item.toString()).toList();
      return Container(
          height: 120,
          width: MediaQuery.of(context).size.width,
          decoration: const BoxDecoration(
            color: Colors.white,
            //  border: Border.all(color: Colors.black)
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                  onTap: () {
                    // showModalSheet(context, null);
                    showDetailItem(context, merchandise[index]);
                  },
                  onDoubleTap: () {
                    print(
                        "like this double tap, ${merchandise[index]['name']}, ${index + 1}");
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(5),
                    child: Container(
                      height: MediaQuery.of(context).size.height,
                      width: 90,
                      decoration: BoxDecoration(
                          color: Colors.grey,
                          borderRadius:
                              const BorderRadius.all(Radius.circular(20)),
                          image: DecorationImage(
                              image: CachedNetworkImageProvider(
                                  publicApiUrl + merchandise[index]['picture']),
                              fit: BoxFit.cover)
                          // border: Border.all()
                          ),
                    ),
                  )),
              Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: MediaQuery.of(context).size.width - 160,
                          child: Text(
                            merchandise[index]['name'],
                            style: const TextStyle(
                                fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ),
                        SizedBox(
                          height: 45, // Atur tinggi kotak scroll
                          // decoration: BoxDecoration(
                          //     border: Border.all(color: Colors.grey)),
                          width: MediaQuery.of(context).size.width - 160,
                          child: SingleChildScrollView(
                              child: Padding(
                                  padding: const EdgeInsets.only(top: 10),
                                  child: Wrap(
                                    spacing:
                                        5.0, // Jarak horizontal antar kotak
                                    runSpacing:
                                        2.0, // Jarak vertikal antar kotak
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
                                  ))),
                        ),
                      ],
                    ),
                    Text(
                      formatCurrency(merchandise[index]['price'].toDouble()),
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color.fromARGB(255, 23, 85, 136)),
                    ),
                  ],
                ),
              ),
              Padding(
                  padding: const EdgeInsets.only(right: 5),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      GestureDetector(
                          onTap: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => MerchandiseUpsert(
                                      name: merchandise[index]['name'],
                                      desc: merchandise[index]['description'],
                                      pathImage: merchandise[index]['picture'],
                                      price: merchandise[index]['price']
                                          .toString(),
                                      merchandiseId: merchandise[index]['ID'],
                                      tag: merchandise[index]['tag'] ?? [],
                                      merchantId: merchandise[index]
                                              ['merchant_id']
                                          .toString())),
                            );
                            _refresh();
                          },
                          child: const Icon(Icons.edit_note_outlined,
                              color: Colors.green, size: 35)),
                      GestureDetector(
                          onTap: () {
                            print("delete");
                            deleteConfirm(merchandise[index]['ID'],
                                merchandise[index]['name']);
                          },
                          child: const Icon(
                            Icons.delete,
                            color: Colors.red,
                          ))
                    ],
                  ))
            ],
          ));
    }
  }

  String formatCurrency(double amount) {
    final formatter = NumberFormat.currency(
      locale: 'id_ID', // Locale untuk Indonesia
      symbol: 'Rp', // Simbol mata uang Rupiah
      decimalDigits: 0, // Jumlah digit desimal
    );
    return formatter.format(amount);
  }

  void _showAlertDialog(String message, String title) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          backgroundColor: Colors.white,
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                'OK',
                style: TextStyle(color: Colors.blue),
              ),
            ),
          ],
        );
      },
    );
  }

  showModalSheet(BuildContext context, data) {
    showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) {
        return Container(
            height: 400,
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(16)),
            child: Padding(
                padding: const EdgeInsets.only(left: 20, top: 20),
                child: Column(
                  // mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    // ignore: avoid_unnecessary_containers
                    Container(
                        height: 40,
                        decoration: const BoxDecoration(color: Colors.white),
                        width: MediaQuery.of(context).size.width,
                        child: const Align(
                            alignment: Alignment.topCenter,
                            child: Text('control',
                                style:
                                    TextStyle(fontWeight: FontWeight.bold)))),
                    GestureDetector(
                        onTap: () async {
                          print("Edit Merchant");
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => MerchantCreate(
                                      name: merchant['name'],
                                      desc: merchant['description'],
                                      pathImage: merchant['picture'],
                                      merchantId: merchant['ID'],
                                    )),
                          );
                          _refresh();
                        },
                        child: Container(
                            height: 30,
                            decoration:
                                const BoxDecoration(color: Colors.white),
                            child: const Row(
                              children: [
                                Icon(Icons.store_outlined),
                                Padding(
                                  padding: EdgeInsets.only(left: 5),
                                  child: Text("Edit Merchant"),
                                )
                              ],
                            ))),
                    Divider(color: Colors.grey[100]),

                    GestureDetector(
                        onTap: () async {
                          print('Add Item');
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => MerchandiseUpsert(
                                      name: '',
                                      desc: '',
                                      pathImage: '',
                                      price: '',
                                      merchandiseId: 0,
                                      tag: const [],
                                      merchantId: merchant['ID'].toString(),
                                    )),
                          );
                          _refresh();
                        },
                        child: Container(
                            height: 30,
                            decoration:
                                const BoxDecoration(color: Colors.white),
                            width: MediaQuery.of(context).size.width,
                            child: const Row(
                              children: [
                                Icon(Icons.add_box_outlined),
                                Padding(
                                  padding: EdgeInsets.only(left: 5),
                                  child: Text("Add Item"),
                                )
                              ],
                            ))),
                    Divider(color: Colors.grey[100]),
                    GestureDetector(
                        onTap: () async {
                          await Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => LandingimageMerchant(
                                        merchantId: merchant['ID'].toString(),
                                        landingImage:
                                            merchant['landing_images'],
                                      )));
                          _refresh();
                        },
                        child: Container(
                            height: 30,
                            decoration:
                                const BoxDecoration(color: Colors.white),
                            width: MediaQuery.of(context).size.width,
                            child: const Row(
                              children: [
                                Icon(Icons.photo_library_outlined),
                                Padding(
                                  padding: EdgeInsets.only(left: 5),
                                  child: Text("Landing Image"),
                                )
                              ],
                            ))),
                    Divider(color: Colors.grey[100]),
                  ],
                )));
      },
    );
  }

  Future<void> fetchMyMerchant() async {
    setState(() {
      isLoad = true;
    });
    final response = await MerchantServices.fetchMyMerchant(false);
    if (response != null) {
      if (response == 401) {
        print("Unauthorized 401");
      } else {
        print("fetch merchang: ${response['data']['name']}");
        List merchandiseData = response['data']['merchandise'];
        // if (mounted) {
        setState(() {
          merchant = response['data'];
          landingImage = response['data']['landing_images'];
          if (merchandiseData.isEmpty) {
            merchandise = ['0'];
          } else {
            merchandise = merchandiseData;
          }
        });
        // }
      }
    } else {
      const SnackBar(content: Text("Something went Wrong"));
    }
    if (merchant.isNotEmpty) _updatePalette();
    setState(() {
      isLoad = false;
    });
  }

  Future<void> deleteMerchindise(id, name) async {
    final response = await MerchantServices.deleteMerchandise(id);
    if (response != null) {
      if (response == 401) {
        print("Unauthorized 401");
      } else {
        _showAlertDialog("Item [$name] deleted!", "Delete Item");
      }
    } else {
      const SnackBar(content: Text("Something went Wrong"));
    }
  }
}
