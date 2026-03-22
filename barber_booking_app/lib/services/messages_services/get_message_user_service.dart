import 'dart:convert';

import 'package:barber_booking_app/models/messages_models/response/get_messages_user_response.dart';
import 'package:http/http.dart' as http;

class GetMessageUserService {
  final String baseUrl = 'http://192.168.0.100:5088';

  Future<List<GetMessagesUserResponse>?> getMessages(String? token) async {
    if (token == null || token.isEmpty) return null;

    try {
      final url = Uri.parse('$baseUrl/api/Message/get-messages');
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        return jsonList
            .map((item) => GetMessagesUserResponse.fromJson(item))
            .toList();
      }

      // Backend returns 400 when the list is empty.
      if (response.statusCode == 400) {
        return [];
      }

      return null;
    } catch (_) {
      return null;
    }
  }
}
