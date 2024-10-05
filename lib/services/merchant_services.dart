import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:sana_mobile/services/user_services.dart';

class MerchantServices {
  static Future fetchMerchantId(id) async {
    print("call api merchant id : $id");
    String apiUrl = UserServices.apiUrl();
    var url =
        '$apiUrl/api/merchants/$id';
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
}
