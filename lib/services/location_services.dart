import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sana_mobile/services/user_services.dart';

class LocationServices {
  static Future<Map?> fetchMyLocation() async {
    String apiUrl = UserServices.apiUrl();
    var url = '$apiUrl/api/locations?my=1';
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

  static Future fetchNearestLocations(
      lat, long, radius, page, page_size, itemName, item) async {
    print("call api location, lat: $lat, long: $long");
    String apiUrl = UserServices.apiUrl();
    var url = '$apiUrl/api/locations/nearest'
        '?latitude=$lat&longitude=$long&radius=$radius&page=$page&page_size=$page_size'
        '&excludemy=true&merchandise=$item';
    if (itemName != null) url = '$url&itemname=$itemName';
    String? token = await UserServices.checkToken();
    final uri = Uri.parse(url);
    final response = await http.get(uri, headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    }).timeout(const Duration(seconds: 30));
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map;
      final result = json['data'] as List;
      print("total: ${result.length}");
      Map data = {'data': result};
      return data;
    } else if (response.statusCode == 401) {
      await UserServices.handleUnauthorized();
      return 401;
    }
    return null;
  }

  static Future getNewLatlong(lat, long) async {
    print("POST socket lat: $lat");
    print("POST socket long: $long");

    String? token = await UserServices.checkToken();
    String? apiUrl = UserServices.apiUrl();
    final response = await http.get(
      Uri.parse('$apiUrl/api/locations/new?lat=$lat&long=$long'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    // final json = jsonDecode(response.body) as Map;
    if (response.statusCode != 200) {
      print('Terjadi kesalahan: ${response.statusCode}');
      await UserServices.handleUnauthorized();
      return false;
    } else {
      // print('Latlong posted to API: ${json['data']}');
      return true;
    }
  }
}
