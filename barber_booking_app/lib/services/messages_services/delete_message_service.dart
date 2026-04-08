import 'dart:convert';

import 'package:barber_booking_app/config/api_config.dart';
import 'package:http/http.dart' as http;

class DeleteMessageService {
  Future<String?> deleteMessage(String? token, String messageId) async {
    if (token == null || token.isEmpty) {
      return 'Требуется авторизация';
    }
    try {
      final url =
          Uri.parse('$kApiBaseUrl/api/Message/delete-message/$messageId');
      final response = await http.delete(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return null;
      }

      if (response.statusCode == 400 && response.body.isNotEmpty) {
        try {
          final decoded = json.decode(response.body);
          if (decoded is String) return decoded;
          if (decoded is Map && decoded['error'] != null) {
            return decoded['error'].toString();
          }
        } catch (_) {}
      }

      return 'Не удалось удалить уведомление';
    } catch (_) {
      return 'Ошибка сети';
    }
  }
}
