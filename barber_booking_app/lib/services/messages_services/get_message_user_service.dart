import 'dart:convert';

import 'package:barber_booking_app/config/api_config.dart';
import 'package:barber_booking_app/models/messages_models/response/get_messages_user_response.dart';
import 'package:barber_booking_app/services/auth_services/auth_http_headers.dart';
import 'package:http/http.dart' as http;

class GetMessageUserService {
  Future<List<GetMessagesUserResponse>?> getMessages() async {
    final headers = await AuthHttpHeaders.bearerJson();
    if (headers == null) return null;

    try {
      final url = Uri.parse('$kApiBaseUrl/api/Message/get-messages');
      final response = await http.get(
        url,
        headers: headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        return jsonList
            .map((item) => GetMessagesUserResponse.fromJson(item))
            .toList();
      }

      if (response.statusCode == 400) {
        return [];
      }

      return null;
    } catch (_) {
      return null;
    }
  }
}
