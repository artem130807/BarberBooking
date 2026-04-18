import 'dart:convert';

import 'package:barber_booking_app/config/api_config.dart';
import 'package:barber_booking_app/services/auth_services/auth_session_binding.dart';
import 'package:http/http.dart' as http;

class GetCountMessagesService {
  Future<int> getCountUnreadMessages() async {
    final token = await AuthSessionBinding.instance.accessToken();
    if (token == null || token.isEmpty) return 0;

    try {
      final url =
          Uri.parse('$kApiBaseUrl/api/Message/get-unread-count-messages');
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

  Future<int> getCountMessages() => getCountUnreadMessages();
}
