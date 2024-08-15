import 'dart:convert';
import 'package:http/http.dart' as http;

class LocationServices {
  static Future<Map?> fetchMyLocation() async {
    const url =
        'https://6b09-2404-8000-1024-c92-85a9-c4bd-d06b-22d8.ngrok-free.app/api/locations?my=1';
    const token =
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJhdXRob3JpemVkIjp0cnVlLCJleHAiOjE3MjM3MjE5MjgsInVzZXJfaWQiOjF9.mmRoMhMmvt9OwFNSNMUTON8e_c7DXN71Vph5Xfec0XM';
    final uri = Uri.parse(url);
    final response = await http.get(uri, headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    });
    print('Get location status : ${response.statusCode}');
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map;
      final result = json['data'] as Map;
      Map data = {'data': result};
      return data;
    } else {
      return null;
    }
  }
}
