import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:sana_mobile/services/location_services.dart';

class MerchantServices {
  static Future fetchMerchantId(id) async {
    print("call api merchant id : $id");
    var url = 'https://f37a-2a09-bac5-3a13-18be-00-277-3e.ngrok-free.app'
        '/api/merchants/$id';
    String? token = await LocationServices.checkToken();
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
}
