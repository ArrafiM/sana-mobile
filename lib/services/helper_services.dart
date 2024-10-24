import 'dart:io';
import 'dart:typed_data';
import 'package:intl/intl.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

class HelperServices {
  static String formatCurrency(double amount) {
    final formatter = NumberFormat.currency(
      locale: 'id_ID', // Locale untuk Indonesia
      symbol: 'Rp', // Simbol mata uang Rupiah
      decimalDigits: 0, // Jumlah digit desimal
    );
    return formatter.format(amount);
  }

  static Future<Uint8List?> compressFile(File file) async {
    var result = await FlutterImageCompress.compressWithFile(
      file.absolute.path,
      minWidth: 800,
      minHeight: 600,
      quality: 70,
    );
    return result;
  }
}
