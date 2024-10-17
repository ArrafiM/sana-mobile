import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:sana_mobile/services/user_services.dart';
import 'package:multi_image_picker_plus/multi_image_picker_plus.dart';

class MerchantServices {
  static Future fetchMerchantId(id) async {
    print("call api merchant id : $id");
    String apiUrl = UserServices.apiUrl();
    var url = '$apiUrl/api/merchants/$id';
    String? token = await UserServices.checkToken();
    final uri = Uri.parse(url);
    final response = await http.get(uri, headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    }).timeout(const Duration(seconds: 30));
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map;
      return json;
    } else if (response.statusCode == 401) {
      return 401;
    }
    return null;
  }

  static Future fetchMyMerchant() async {
    print("call api my merchant data");
    String apiUrl = UserServices.apiUrl();
    var url = '$apiUrl/api/mymerchants';
    String? token = await UserServices.checkToken();
    final uri = Uri.parse(url);
    final response = await http.get(uri, headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    }).timeout(const Duration(seconds: 30));
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map;
      return json;
    } else if (response.statusCode == 401) {
      return 401;
    }
    return null;
  }

  static Future createMerchant(String name, String desc, File? picture) async {
    String? token = await UserServices.checkToken();
    String apiurl = UserServices.apiUrl();
    var url = Uri.parse('$apiurl/api/merchants');
    var request = http.MultipartRequest('POST', url)
      ..headers['Authorization'] = 'Bearer $token'
      ..fields['name'] = name
      ..fields['description'] = desc
      ..files.add(
        await http.MultipartFile.fromPath(
          'picture',
          picture!.path,
        ),
      );
    var response = await request.send();
    // final json = jsonDecode(response.body) as Map;
    if (response.statusCode != 201) {
      print('Terjadi kesalahan: ${response.statusCode}');
      return false;
    } else {
      print('Merchant created!: $name');
      return true;
    }
  }

  static Future putMerchant(
      int id, String name, String desc, File? picture) async {
    String? token = await UserServices.checkToken();
    String apiurl = UserServices.apiUrl();
    var url = Uri.parse('$apiurl/api/merchants/$id');
    var request = http.MultipartRequest('PUT', url)
      ..headers['Authorization'] = 'Bearer $token'
      ..fields['name'] = name
      ..fields['description'] = desc;
    if (picture != null) {
      request.files.add(
        await http.MultipartFile.fromPath(
          'picture',
          picture.path,
        ),
      );
    }

    var response = await request.send();
    // final json = jsonDecode(response.body) as Map;
    if (response.statusCode != 200) {
      print('Terjadi kesalahan: ${response.statusCode}');
      return false;
    } else {
      print('Merchant updated!: $name');
      return true;
    }
  }

  static Future createMerchandise(String name, String desc, File? picture,
      String price, String merchantId) async {
    String? token = await UserServices.checkToken();
    String apiurl = UserServices.apiUrl();
    var url = Uri.parse('$apiurl/api/merchandise');
    var request = http.MultipartRequest('POST', url)
      ..headers['Authorization'] = 'Bearer $token'
      ..fields['name'] = name
      ..fields['description'] = desc
      ..fields['price'] = price
      ..fields['merchant_id'] = merchantId;
    if (picture != null) {
      request.files.add(
        await http.MultipartFile.fromPath(
          'picture',
          picture.path,
        ),
      );
    }
    var response = await request.send();
    // final json = jsonDecode(response.body) as Map;
    if (response.statusCode != 201) {
      print('Terjadi kesalahan post: merchandise ${response.statusCode}');
      return false;
    } else {
      print('Merchandise created!: $name');
      return true;
    }
  }

  static Future putMerchandise(int id, String name, String desc, File? picture,
      String price, String merchantId) async {
    String? token = await UserServices.checkToken();
    String apiurl = UserServices.apiUrl();
    var url = Uri.parse('$apiurl/api/merchandise/$id');
    var request = http.MultipartRequest('PUT', url)
      ..headers['Authorization'] = 'Bearer $token'
      ..fields['name'] = name
      ..fields['description'] = desc
      ..fields['price'] = price
      ..fields['merchant_id'] = merchantId;
    if (picture != null) {
      request.files.add(
        await http.MultipartFile.fromPath(
          'picture',
          picture.path,
        ),
      );
    }
    var response = await request.send();
    // final json = jsonDecode(response.body) as Map;
    if (response.statusCode != 200) {
      print('Terjadi kesalahan put: merchandise ${response.statusCode}');
      return false;
    } else {
      print('Merchandise Updated!: $name');
      return true;
    }
  }

  static Future uploadMerchantImages(
      String merchantId, List<Asset> images, List<int> removeId) async {
    print("upload landing image merchant id: $merchantId");

    // return false;
    String? token = await UserServices.checkToken();
    String apiurl = UserServices.apiUrl();
    var url = Uri.parse('$apiurl/api/merchants/uploadlanding');
    var request = http.MultipartRequest('POST', url)
      ..headers['Authorization'] = 'Bearer $token'
      ..fields['merchant_id'] = merchantId;
    if (images.isNotEmpty) {
      for (var asset in images) {
        var byteData = await asset.getByteData();
        var multipartFile = http.MultipartFile.fromBytes(
          'files[]', // Nama field di API
          byteData.buffer.asUint8List(),
          filename: asset.name,
        );
        request.files.add(multipartFile);
      }
    }
    if (removeId.isNotEmpty) {
      request.fields['remove_id'] = "$removeId";
    }
    var response = await request.send();
    // final json = jsonDecode(response.body) as Map;
    if (response.statusCode != 201) {
      print('Terjadi kesalahan post: merchandise ${response.statusCode}');
      return false;
    } else {
      print('Merchant image uploaded!: true');
      return true;
    }
  }
}
