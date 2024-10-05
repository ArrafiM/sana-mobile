import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class UserServices {
  static Future<Map?> fetchUsers() async {
    const url = 'http://192.168.18.32:3030/users/me';
    const token =
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjY1ZDU3OWE2ZGQ5NGIwMDUxZDhjNGNjMyIsImVtYWlsIjoic2FuYXlhQG1haWwuY29tIiwiaWF0IjoxNzA4NTgzOTcxfQ.PM1LjxEZsd6GTQLFPLI_e_wJJ4hD8EsZzxe_yMw3IRY';
    final uri = Uri.parse(url);
    final response = await http.get(uri, headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    });
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map;
      final result = json['data'] as List;
      int totalList = (result.length / 3).round();
      Map data = {'data': result, 'total_list': totalList};
      return data;
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

  static String apiUrl() {
    String apiUrl = "https://7d44-114-122-79-66.ngrok-free.app";
    return apiUrl;
  }

  static Future<String?> checkToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  static Future<String?> checkMyId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_id');
  }

  static Future<void> handleUnauthorized() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('token'); // Hapus token dari SharedPreferences
    // Navigasi ke halaman login
  }
}
