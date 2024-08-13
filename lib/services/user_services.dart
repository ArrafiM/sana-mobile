import 'dart:convert';
import 'package:http/http.dart' as http;

class UserServices {
  static Future<Map?> fetchUsers() async {
    const url = 'http://192.168.18.32:3030/users';
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
}
