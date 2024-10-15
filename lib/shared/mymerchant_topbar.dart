import 'package:flutter/material.dart';
import 'package:sana_mobile/screen/merchandise_upsert.dart';
import 'package:sana_mobile/screen/merchant_create.dart';
import 'package:sana_mobile/shared/logout.dart';

class MyMerchantTopbar extends StatefulWidget implements PreferredSizeWidget {
  final Map<String, dynamic> merchant;
  const MyMerchantTopbar({super.key, required this.merchant});

  @override
  State<MyMerchantTopbar> createState() => _MyMerchantTopbarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _MyMerchantTopbarState extends State<MyMerchantTopbar> {
  Map merchant = {};

  @override
  void initState() {
    super.initState();
    setState(() {
      merchant = widget.merchant;
    });
  }

  @override
  Widget build(BuildContext context) {
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
        IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {
            // Aksi saat tombol notifications ditekan
            showModalSheet(context, null);
          },
        ),
      ],
    );
  }

  void showModalSheet(BuildContext context, data) {
    // if (data != null) {
    //   print("modal dengan data: $data");
    // }
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
                        onTap: () {
                          print("Edit Merchant");
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => MerchantCreate(
                                      name: widget.merchant['name'],
                                      desc: widget.merchant['description'],
                                      pathImage: widget.merchant['picture'],
                                      merchantId: widget.merchant['ID'],
                                    )),
                          );
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
                        onTap: () {
                          print('Add Item');
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => MerchandiseUpsert(
                                      name: '',
                                      desc: '',
                                      pathImage: '',
                                      price: '',
                                      merchandiseId: 0,
                                      merchantId:
                                          widget.merchant['ID'].toString(),
                                    )),
                          );
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
                    ElevatedButton(
                      child: const Text('Logout'),
                      onPressed: () {
                        showLogoutConfirmDialog(context);
                      },
                    ),
                  ],
                )));
      },
    );
  }
}
