import 'dart:async';

import 'package:flutter/material.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:sana_mobile/screen/merchandise_upsert.dart';
import 'package:sana_mobile/screen/merchant_create.dart';
import 'package:sana_mobile/services/merchant_services.dart';
import 'package:sana_mobile/services/socket_services.dart';
import 'package:sana_mobile/services/user_services.dart';
import 'package:sana_mobile/shared/mymerchant_topbar.dart';
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
  bool isLoad = true;
  Map<String, dynamic> merchant = {};
  List landingImage = [];
  String? myId = '';

  List merchandise = ['0'];

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
        setState(() {
          isLoad = true;
        });
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
        // isLoadColor = false;
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
            ? MyMerchantTopbar(merchant: merchant)
            : const SimpleTopBar(),
        body: _myMerchantData());
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
                            onPressed: () {
                              print('Create merchant page');
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const MerchantCreate(
                                          name: '',
                                          desc: '',
                                          pathImage: '',
                                          merchantId: 0,
                                        )),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: Colors.blue, // Text color
                            ),
                            child: const Icon(Icons.add_business_outlined))
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
                  ));
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
                              child: Text(
                                merchandise[index]['description'],
                                style: const TextStyle(fontSize: 12),
                              ),
                            )),
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
                          onTap: () {
                            Navigator.push(
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

  Future<void> fetchMyMerchant() async {
    final response = await MerchantServices.fetchMyMerchant();
    if (response != null) {
      if (response == 401) {
        print("Unauthorized 401");
      } else {
        print("fetch merchang: ${response['data']['name']}");
        List merchandiseData = response['data']['merchandise'];
        if (mounted) {
          setState(() {
            merchant = response['data'];
            landingImage = response['data']['landing_images'];
            if (merchandiseData.isEmpty) {
              merchandise = ['0'];
            } else {
              merchandise = merchandiseData;
            }
          });
        }
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
