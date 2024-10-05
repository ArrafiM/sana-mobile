import 'package:flutter/material.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:sana_mobile/services/helper_services.dart';
import 'package:sana_mobile/services/merchant_services.dart';
import 'package:sana_mobile/services/user_services.dart';
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
                  )));
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
          child: Text("Merchandise: -"),
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
                              image: NetworkImage(
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
                        Text(
                          merchandise[index]['name'],
                          style: const TextStyle(
                              fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width - 160,
                          child: Text(
                            merchandise[index]['description'],
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child: Text(
                        HelperServices.formatCurrency(
                            merchandise[index]['price'].toDouble()),
                        style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color.fromARGB(255, 23, 85, 136)),
                      ),
                    )
                  ],
                ),
              )
            ],
          ));
    }
  }

  Future<void> fetchMerchant(id) async {
    final response = await MerchantServices.fetchMerchantId(id);
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
            isLoad = false;
          });
        }
      }
      print("landing image data: $landingImage");
    } else {
      const SnackBar(content: Text("Something went Wrong"));
    }
  }
}
