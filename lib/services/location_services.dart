import 'dart:convert';
import 'package:http/http.dart' as http;

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

  static Future<Map?> fetchNearestLocations() async {
    const url =
        'https://49d6-2404-8000-1024-c92-54a-a3ea-d392-659.ngrok-free.app/api/locations/nearest';
    const token =
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJhdXRob3JpemVkIjp0cnVlLCJleHAiOjE3MjM3OTEwMTgsInVzZXJfaWQiOjF9.FQbFSraccDmW1cA-vpG20ZyclEKtNr6kiXTL88d8UaI';
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
    } else {
      return null;
    }
  }
}
