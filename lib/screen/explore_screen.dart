import 'package:flutter/material.dart';
import 'package:sana_mobile/services/helper_services.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({Key? key}) : super(key: key);

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  int merchants = 10;
  int item = 3;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            // Search Field
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  hintText: "Search...",
                  fillColor: const Color.fromARGB(255, 237, 236, 236),
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30), // Sudut melengkung
                    borderSide: BorderSide.none, // Hilangkan garis pinggir
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  // prefixIcon: const Icon(Icons.search),
                ),
              ),
            ),
            // Icon Search
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                // Add your search logic here
                print('Search pressed');
              },
            ),
          ],
        ),
      ),
      body: ListView.builder(
          itemCount: merchants,
          itemBuilder: (context, index) {
            if (index == 0) {
              return Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: merchantList(index));
            } else {
              return merchantList(index);
            }
          }),
    );
  }

  SizedBox merchantList(int index) {
    return SizedBox(
      height: 250,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Row(children: [
              const Padding(
                  padding: EdgeInsets.only(left: 10),
                  child: CircleAvatar(
                      radius: 30, child: Icon(Icons.storefront_outlined))),
              Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: Text("Merchant ${index + 1}")),
            ]),
            const Padding(
                padding: EdgeInsets.only(right: 10), child: Text("< 500 m"))
          ]),
          const SizedBox(height: 5), // Beri jarak antar avatar dan list
          itemList()
        ],
      ),
    );
  }

  SizedBox itemList() {
    return SizedBox(
      height: 170, // Tinggi khusus untuk ListView horizontal
      child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.only(left: 10, right: 20),
          separatorBuilder: (context, index) => const SizedBox(
                width: 10,
              ),
          itemCount: item + 1,
          itemBuilder: (context, index) {
            if (index == item) {
              return const Icon(Icons.arrow_circle_right_outlined,
                  size: 35, color: Colors.grey);
            } else {
              return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                        height: 120,
                        width: 130,
                        decoration: BoxDecoration(
                            color: Colors.grey,
                            borderRadius: BorderRadius.circular(10))),
                    Text("Item ke ${index + 1}"),
                    Text(HelperServices.formatCurrency(20000))
                  ]);
            }
          }),
    );
  }
}
