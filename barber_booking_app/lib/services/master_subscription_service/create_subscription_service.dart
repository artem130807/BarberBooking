import 'dart:convert';

import 'package:barber_booking_app/config/api_config.dart';
import 'package:barber_booking_app/models/master_subscription_models/request/create_subscription_request.dart';
import 'package:barber_booking_app/services/auth_services/auth_http_headers.dart';
import 'package:http/http.dart' as http;

class CreateSubscriptionService {
  Future<String?> createSubscription(CreateSubscriptionRequest request) async {
    try {
      final headers = await AuthHttpHeaders.bearerJson();
      if (headers == null) return null;

      final url =
          Uri.parse('$kApiBaseUrl/api/MasterSubscriptions/Create-MasterSubscription');
      final response = await http.post(
        url,
        headers: headers,
        body: json.encode(request.toJson()),
      );
      print('📥 Статус: ${response.statusCode}');
      print('📥 Ответ: ${response.body}');

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        if (decoded is String) return decoded;
        return decoded?.toString();
      } else {
        print('❌ Ошибка сервера: ${response.body}');
        return null;
      }
    } catch (e) {
      print(e);
      return null;
    }
  }
}
