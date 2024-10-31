import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sana_mobile/services/user_services.dart';

class ChatServices {
  static Future fetchChatrooms(page, limit, unreadMsg) async {
    print("call api chatroom");
    String apiUrl = UserServices.apiUrl();
    var url =
        '$apiUrl/api/chatrooms?page_size=$limit&page=$page&unreadmsg=$unreadMsg';
    // '?latitude=$lat&longitude=$long&radius=$radius&page=$page&page_size=$page_size';
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
      final unread = json['unread'] as int;
      print("total: ${result.length}");
      Map data = {'data': result, 'unread': unread};
      return data;
    } else if (response.statusCode == 401) {
      await UserServices.handleUnauthorized();
      return 401;
    }
    return null;
  }

  static Future fetchChattings(roomId, page, limit, readMsg) async {
    print("call api chatroom");
    String? apiUrl = UserServices.apiUrl();
    var url =
        '$apiUrl/api/chats?roomid=$roomId&page=$page&page_size=$limit&readmsg=$readMsg';
    // '?latitude=$lat&longitude=$long&radius=$radius&page=$page&page_size=$page_size';
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

  static Future sendMessage(receiverId, message) async {
    var body = jsonEncode({
      'receiver_id': receiverId,
      'message': message,
    });
    String? token = await UserServices.checkToken();
    String? apiUrl = UserServices.apiUrl();
    final response = await http.post(
      Uri.parse('$apiUrl/api/chats'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
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

  static Future getRoom(receiverId, senderId) async {
    String? apiUrl = UserServices.apiUrl();
    String? token = await UserServices.checkToken();
    String url = '$apiUrl/api/chatroom?sender=$senderId&receiver=$receiverId';
    final uri = Uri.parse(url);
    final response = await http.get(uri, headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    }).timeout(const Duration(seconds: 30));
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map;
      final result = json['data'] as Map;
      return result;
    } else if (response.statusCode == 401) {
      await UserServices.handleUnauthorized();
      return 401;
    }
    return null;
  }
}
