import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:sana_mobile/services/helper_services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:path/path.dart' as path;

class UserServices {
  static Future<Map?> fetchUsers() async {
    String apiurl = apiUrl();
    String? token = await checkToken();
    final uri = Uri.parse('$apiurl/api/users/me');
    final response = await http.get(uri, headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    });

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map;
      // final result = json['data'] as List;
      // int totalList = (result.length / 3).round();
      // Map data = {'data': result, 'total_list': totalList};
      return json;
    } else {
      return null;
    }
  }

  static Future authentication(email, password) async {
    var body = jsonEncode({
      'email': email,
      'password': password,
    });
    String apiurl = apiUrl();
    final response = await http.post(
      Uri.parse('$apiurl/api/auth/login'),
      body: body,
    );
    final json = jsonDecode(response.body) as Map;
    if (response.statusCode != 200) {
      print('Terjadi kesalahan: ${response.statusCode}');
      return json;
    } else {
      print('Token valid');
      return json;
    }
  }

  static Future authRegister(data) async {
    var body = jsonEncode({
      'name': data['name'],
      'email': data['email'],
      'password': data['password'],
      'confirm_password': data['confirm_password'],
    });
    String apiurl = apiUrl();
    final response = await http.post(
      Uri.parse('$apiurl/api/auth/register'),
      body: body,
    );
    final json = jsonDecode(response.body) as Map;
    if (response.statusCode != 200) {
      print('Terjadi kesalahan: ${response.statusCode}');
      return json;
    } else {
      print('register success!');
      return json;
    }
  }

  static Future putUser(String name, File? picture) async {
    String? token = await UserServices.checkToken();
    String apiurl = apiUrl();
    var url = Uri.parse('$apiurl/api/users/update');
    var request = http.MultipartRequest('PUT', url)
      ..headers['Authorization'] = 'Bearer $token'
      ..fields['name'] = name;
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
      print('User updated!: $name');
      return true;
    }
  }

  static Future changePass(data) async {
    var body = jsonEncode({
      'oldpass': data['oldpass'],
      'newpass': data['newpass'],
      'confirm_newpass': data['confirm_newpass'],
    });
    String? token = await UserServices.checkToken();
    String apiurl = apiUrl();
    final response = await http.put(
      Uri.parse('$apiurl/api/users/changepass'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: body,
    );
    final json = jsonDecode(response.body) as Map;
    if (response.statusCode != 200) {
      print('Terjadi kesalahan: ${response.statusCode}');
      return json;
    } else {
      print('register success!');
      return json;
    }
  }

  static String apiUrl() {
    String apiUrl = "${dotenv.env['API_URL']}";
    return apiUrl;
  }

  static Future wsUrl() async {
    String? userId = await UserServices.checkMyId();
    var wsUrl = dotenv.env['WS_URL'];
    return '$wsUrl?user_id=user$userId';
  }

  static Future<String?> checkToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  static Future<String?> checkMyId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_id');
  }

  static Future<String?> getLocaData(String name) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(name);
  }

  static Future<void> handleUnauthorized() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('token'); // Hapus token dari SharedPreferences
    // Navigasi ke halaman login
  }
}
