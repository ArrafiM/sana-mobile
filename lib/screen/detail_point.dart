import 'package:flutter/material.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:sana_mobile/screen/chatroom_screen.dart';
import 'package:sana_mobile/services/chat_services.dart';
import 'package:sana_mobile/services/helper_services.dart';
import 'package:sana_mobile/services/merchant_services.dart';
import 'package:sana_mobile/services/user_services.dart';
import 'package:sana_mobile/shared/detail_item.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class DetailPoint extends StatefulWidget {
  final Map<String, dynamic> point;

  const DetailPoint({
    Key? key,
    required this.point,
  }) : super(key: key);

  @override
  State<DetailPoint> createState() => _DetailPointState();
}

class _DetailPointState extends State<DetailPoint> {
  final PageController _pageController = PageController();
  late ScrollController _scrollController;
  Map<String, dynamic> pointData = {};
  Color backgroundColorLanding = Colors.white;
  String publicApiUrl = "";
  bool isLoad = true;
  Map<String, dynamic> merchant = {};
  List landingImage = [];
  Map user = {};
  Map chatRoom = {};
  String? senderId;
  int page = 1;
  int pageSize = 10;
  bool isLoadItem = false;

  List merchandise = ['0'];

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    String apiUrl = UserServices.apiUrl();
    setState(() {
      publicApiUrl = "$apiUrl/public/";
      pointData = widget.point;
    });
    _updatePalette();
    _myId();
    fetchMerchant(pointData['merchant']['ID']);
  }

  Future<void> _updatePalette() async {
    if (pointData['merchant']['picture'] != "") {
      final imageProvider =
          NetworkImage("$publicApiUrl${pointData['merchant']['picture']}");
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
    fetchMerchant(pointData['merchant']['ID']);
  }

  Future _myId() async {
    String? userId = await UserServices.checkMyId();
    setState(() {
      senderId = userId;
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
        ),
        body: RefreshIndicator(
            onRefresh: _refresh,
            child: isLoad
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : _listViewItem()),
        floatingActionButton: Padding(
          padding: const EdgeInsets.only(right: 5, bottom: 5),
          child: FloatingActionButton(
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ChatroomScreen(room: chatRoom)));
            },
            child: const Icon(Icons.question_answer),
          ),
        ));
  }

  ListView _listViewItem() {
    return ListView.builder(
      controller: _scrollController,
      itemCount: merchandise.length + (isLoadItem ? 1 : 0),
      padding: const EdgeInsets.only(top: 0),
      itemBuilder: (context, index) {
        if (index == 0) {
          return Column(children: [
            landingImage.isEmpty ? const SizedBox.shrink() : merchantHeader(),
            landingImage.isEmpty ? const SizedBox.shrink() : sliderIndicator(),
            merchantDetail(context),
            merchandiseTitle(),
            _merchandiseList(index),
          ]);
        } else if (index < merchandise.length) {
          return _merchandiseList(index);
        } else {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: CircularProgressIndicator(),
            ),
          );
        }
      },
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
              "Merchandise list:",
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
              pointData['merchant']['picture'] != ""
                  ? CircleAvatar(
                      backgroundImage: NetworkImage(
                          publicApiUrl + pointData['merchant']['picture']),
                      radius: 50,
                    )
                  : const CircleAvatar(
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
                        "${pointData['merchant']['name']}",
                        style: const TextStyle(
                            fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        "${pointData['merchant']['description']}",
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
      List<dynamic> items = merchandise[index]["tag"] ?? [];
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
                    showDetailItem(context, merchandise[index]);
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
                              image: NetworkImage(
                                  publicApiUrl + merchandise[index]['picture']),
                              fit: BoxFit.cover)),
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
                        _tagItem(stringItems),
                      ],
                    ),
                    Text(
                      HelperServices.formatCurrency(
                          merchandise[index]['price'].toDouble()),
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color.fromARGB(255, 23, 85, 136)),
                    ),
                  ],
                ),
              )
            ],
          ));
    }
  }

  SizedBox _tagItem(List<String> stringItems) {
    return SizedBox(
      height: 45, // Atur tinggi kotak scroll
      // decoration: BoxDecoration(
      //     border: Border.all(color: Colors.grey)),
      width: MediaQuery.of(context).size.width - 160,
      child: SingleChildScrollView(
          child: Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Wrap(
                spacing: 5.0, // Jarak horizontal antar kotak
                runSpacing: 2.0, // Jarak vertikal antar kotak
                children: stringItems
                    .map<Widget>((tag) => Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            border: Border.all(color: Colors.grey),
                          ),
                          child: Text(
                            tag,
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ))
                    .toList(), // Konversi ke List<Widget>
              ))),
    );
  }

  Future<void> fetchMerchant(id) async {
    final response =
        await MerchantServices.fetchMerchantId(id, true, true, false);
    if (response != null) {
      if (response == 401) {
        print("Unauthorized 401");
      } else {
        Map userData = response['data']['user'];
        if (mounted) {
          setState(() {
            merchant = response['data'];
            user = userData;
            landingImage = response['data']['landing_images'];
            if (merchandise.isEmpty) {
              merchandise = ['0'];
            }
            chatRoom = {
              "ID": 0,
              "receiverdata": {
                "id": userData['ID'],
                "name": userData['name'],
                "picture": userData['picture']
              }
            };
            isLoad = false;
          });
          fetchGetRoom(userData['ID']);

          _fetchMerchantdise(id);
          _scrollListener(id);
        }
      }
    } else {
      const SnackBar(content: Text("Something went Wrong"));
    }
  }

  Future _scrollListener(id) async {
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent) {
        if (!isLoadItem) {
          _fetchMerchantdise(id);
        }
      }
    });
  }

  Future<void> _fetchMerchantdise(merchantId) async {
    setState(() {
      isLoadItem = true;
    });
    print('HIT merchandise api, id $merchantId, page: $page');
    final item = await MerchantServices.fetchMerchandise(
        merchantId, true, page, pageSize, null, null);
    if (item['data'] != null) {
      List merchandiseData = item['data'];
      if (merchandiseData.isNotEmpty) {
        setState(() {
          page++;
          if (merchandise[0] == '0') {
            merchandise = merchandiseData;
          } else {
            merchandise.addAll(merchandiseData);
          }
        });
      }
    }
    setState(() {
      isLoadItem = false;
    });
  }

  Future<void> fetchGetRoom(receiverId) async {
    final response = await ChatServices.getRoom(receiverId, senderId);
    if (response != null) {
      setState(() {
        chatRoom['ID'] = response['ID'];
      });
    } else {
      // const SnackBar(content: Text("Something went Wrong"));
    }
  }
}
