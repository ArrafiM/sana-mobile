import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:sana_mobile/services/user_services.dart';
import 'package:intl/intl.dart';

String formatCurrency(double amount) {
  final formatter = NumberFormat.currency(
    locale: 'id_ID', // Locale untuk Indonesia
    symbol: 'Rp', // Simbol mata uang Rupiah
    decimalDigits: 0, // Jumlah digit desimal
  );
  return formatter.format(amount);
}

showDetailItem(BuildContext context, data) {
  String apiUrl = UserServices.apiUrl();
  String publicApiUrl = "$apiUrl/public/";

  showModalBottomSheet<void>(
    context: context,
    builder: (BuildContext context) {
      return Container(
          height: 400,
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(16)),
          child: Padding(
              padding: const EdgeInsets.only(left: 30, top: 30),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 240,
                      width: MediaQuery.of(context).size.width - 60,
                      decoration: BoxDecoration(
                          color: Colors.grey,
                          borderRadius: BorderRadius.circular(16),
                          image: DecorationImage(
                              image: CachedNetworkImageProvider(
                                  publicApiUrl + data['picture']),
                              fit: BoxFit.cover)),

                      // border: Border.all()
                    ),
                    Padding(
                        padding: const EdgeInsets.only(left: 10, top: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width - 160,
                                  child: Text(
                                    data['name'],
                                    style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(right: 30),
                                  child: Text(
                                      formatCurrency(data['price'].toDouble()),
                                      style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold)),
                                )
                              ],
                            ),
                            SizedBox(
                                height: 80, // Atur tinggi kotak scroll
                                // decoration: BoxDecoration(
                                //     border: Border.all(color: Colors.grey)),
                                width: MediaQuery.of(context).size.width - 60,
                                child: SingleChildScrollView(
                                  child: Text(
                                    data['description'],
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                )),
                          ],
                        ))
                  ])));
    },
  );
}
