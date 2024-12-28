import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:sana_mobile/services/helper_services.dart';
import 'package:sana_mobile/services/user_services.dart';
import 'package:multi_image_picker_plus/multi_image_picker_plus.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';

class MerchantServices {
  static Future fetchMerchantId(id, bool user, bool image, bool item) async {
    print("call api merchant id : $id");
    String apiUrl = UserServices.apiUrl();
    var url = '$apiUrl/api/merchants/$id?';
    if (user) url = '${url}user=true&';
    if (image) url = '${url}image=true&';
    if (item) url = '${url}item=true&';
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

  static Future fetchMyMerchant(bool isCek, bool image) async {
    print("call api my merchant data");
    String apiUrl = UserServices.apiUrl();
    var url = '$apiUrl/api/mymerchants?';
    if (isCek) {
      url = '${url}cek=true&';
    }
    if (image) {
      url = '${url}image=true';
    }
    print("url merchant: $url");
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

  static Future fetchMerchandise(merchantId, bool? isActive, int? page,
      int? pageSize, last, update) async {
    String? token = await UserServices.checkToken();
    String apiUrl = UserServices.apiUrl();
    String url = '$apiUrl/api/merchandise?merchant_id=$merchantId';
    if (isActive != null) {
      url = '$url&isactive=$isActive';
    }
    url = '$url&page=$page&page_size=$pageSize&last=$last&update=$update';
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
      ..fields['status'] = 'inactive'
      ..files.add(
        await http.MultipartFile.fromPath(
          'picture',
          picture!.path,
        ),
      );
    var response = await request.send();

    if (response.statusCode != 201) {
      print('Terjadi kesalahan: ${response.statusCode}');
      return false;
    } else {
      print('Merchant created!: $name');
      var responseData = await http.Response.fromStream(response);
      final json = jsonDecode(responseData.body) as Map;
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String merchantId = json['data']['ID'].toString();
      print('save merchant id to local storage: $merchantId');
      await prefs.setString('merchant_id', merchantId);
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
      Uint8List? image = await HelperServices.compressFile(picture);
      request.files.add(
        http.MultipartFile.fromBytes(
          'picture', // Nama field sesuai API yang menerima file
          image!.toList(),
          filename: path.basename(picture.path), // Nama file yang akan diupload
          // contentType: MediaType('image', 'jpeg'), // Ubah sesuai tipe file
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
      String price, String merchantId, List tagdata) async {
    String? token = await UserServices.checkToken();
    String apiurl = UserServices.apiUrl();
    var url = Uri.parse('$apiurl/api/merchandise');
    var request = http.MultipartRequest('POST', url)
      ..headers['Authorization'] = 'Bearer $token'
      ..fields['name'] = name
      ..fields['description'] = desc
      ..fields['price'] = price
      ..fields['merchant_id'] = merchantId;
    if (tagdata.isNotEmpty) {
      request.fields['tag'] = tagdata.toString();
    }
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
      String price, String merchantId, List tagdata) async {
    String? token = await UserServices.checkToken();
    String apiurl = UserServices.apiUrl();
    var url = Uri.parse('$apiurl/api/merchandise/$id');
    var request = http.MultipartRequest('PUT', url)
      ..headers['Authorization'] = 'Bearer $token'
      ..fields['name'] = name
      ..fields['description'] = desc
      ..fields['price'] = price
      ..fields['merchant_id'] = merchantId;
    if (tagdata.isNotEmpty) {
      request.fields['tag'] = tagdata.toString();
    }
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

  static Future deleteMerchandise(id) async {
    print("hit api delete merchant id : $id");
    String apiUrl = UserServices.apiUrl();
    var url = '$apiUrl/api/merchandise/$id';
    String? token = await UserServices.checkToken();
    final uri = Uri.parse(url);
    final response = await http.delete(uri, headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    }).timeout(const Duration(seconds: 30));
    if (response.statusCode == 200) {
      return true;
    } else if (response.statusCode == 401) {
      return 401;
    }
    return null;
  }

  static Future activateItem(int id, bool isActive) async {
    String? token = await UserServices.checkToken();
    String apiurl = UserServices.apiUrl();
    var url = Uri.parse('$apiurl/api/merchandise/$id');
    var request = http.MultipartRequest('PUT', url)
      ..headers['Authorization'] = 'Bearer $token'
      ..fields['active'] = isActive.toString();
    var response = await request.send();
    // final json = jsonDecode(response.body) as Map;
    if (response.statusCode != 200) {
      print('Terjadi kesalahan put: merchandise ${response.statusCode}');
      return false;
    } else {
      print('Merchandise Activate update!: $id to [$isActive]');
      return true;
    }
  }

  static Future activeMerchant(int id, String status) async {
    String? token = await UserServices.checkToken();
    String apiurl = UserServices.apiUrl();
    var url = Uri.parse('$apiurl/api/merchants/$id');
    var request = http.MultipartRequest('PUT', url)
      ..headers['Authorization'] = 'Bearer $token'
      ..fields['status'] = status;
    var response = await request.send();
    if (response.statusCode != 200) {
      print('Terjadi kesalahan: ${response.statusCode}');
      return false;
    } else {
      print('Merchant active!: $status');
      return true;
    }
  }
}
