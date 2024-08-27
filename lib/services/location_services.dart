import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class LocationServices {
  static Future<Map?> fetchMyLocation() async {
    const url =
        'https://49d6-2404-8000-1024-c92-54a-a3ea-d392-659.ngrok-free.app/api/locations?my=1';
    const token =
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJhdXRob3JpemVkIjp0cnVlLCJleHAiOjE3MjM3OTEwMTgsInVzZXJfaWQiOjF9.FQbFSraccDmW1cA-vpG20ZyclEKtNr6kiXTL88d8UaI';
    final uri = Uri.parse(url);
    final response = await http.get(uri, headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    });
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map;
      final result = json['data'] as Map;
      Map data = {'data': result};
      return data;
    } else {
      return null;
    }
  }

  static Future<String?> checkToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  static Future<void> handleUnauthorized() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('token'); // Hapus token dari SharedPreferences
    // Navigasi ke halaman login
  }

  static Future fetchNearestLocations(lat, long) async {
    print("call api location, lat: $lat, long: $long");
    var url = 'https://b530-182-253-124-160.ngrok-free.app'
        '/api/locations/nearest'
        '?latitude=$lat&longitude=$long&radius=2000&page=1&page_size=100';
    // String token = 'nothing';
    String? token = await checkToken();
    // print("token data: $token");
    // const token =
    //     'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJhdXRob3JpemVkIjp0cnVlLCJleHAiOjE3MjQ3NjI1NTcsInVzZXJfaWQiOjF9.HqHFQwzdcwlChgtaG8coAJNVjSfW3BeVuSJlUjAsbok';
    final uri = Uri.parse(url);
    final response = await http.get(uri, headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    }).timeout(const Duration(seconds: 30));
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map;
      final result = json['data'] as List;
      Map data = {'data': result};
      return data;
    } else if (response.statusCode == 401) {
      // await handleUnauthorized(context);
      await handleUnauthorized();
      return 401;
    }
    return null;
  }
}
