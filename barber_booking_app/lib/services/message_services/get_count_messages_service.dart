import 'dart:convert';

import 'package:http/http.dart' as http;

class GetCountMessagesService {
  final String baseUrl = 'http://192.168.0.100:5088';

  Future<int> getCountUnreadMessages(String? token) async {
    if (token == null || token.isEmpty) return 0;

    try {
      final url = Uri.parse('$baseUrl/api/Message/get-unread-count-messages');
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        if (decoded is int) return decoded;
        return int.tryParse(decoded.toString()) ?? 0;
      }

      return 0;
    } catch (_) {
      return 0;
    }
  }

  Future<int> getCountMessages(String? token) => getCountUnreadMessages(token);
}

