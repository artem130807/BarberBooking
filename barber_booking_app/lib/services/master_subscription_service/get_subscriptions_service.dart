import 'dart:convert';

import 'package:barber_booking_app/config/api_config.dart';
import 'package:barber_booking_app/models/master_subscription_models/response/get_subscriptions_response.dart';
import 'package:barber_booking_app/services/auth_services/auth_http_headers.dart';
import 'package:http/http.dart' as http;

class GetSubscriptionsService {
  Future<List<GetSubscriptionsResponse>?> getSubscriptions() async {
    try {
      final headers = await AuthHttpHeaders.bearerJson();
      if (headers == null) return null;

      final url =
          Uri.parse('$kApiBaseUrl/api/MasterSubscriptions/Get-MasterSubscriptions');

      final response = await http.get(url, headers: headers);

      print('📥 Статус: ${response.statusCode}');
      print('📥 Ответ: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        print('📊 Количество данных: ${jsonList.length}');
        if (jsonList.isEmpty) {
          print('⚠️ Сервер вернул пустой список');
          return [];
        }
        return jsonList
            .map((json) => GetSubscriptionsResponse.fromJson(json))
            .toList();
      } else {
        print('❌ Ошибка сервера: ${response.body}');
        try {
          final errorJson = json.decode(response.body);
          throw Exception(errorJson['error'] ?? 'Неизвестная ошибка');
        } catch (e) {
          throw Exception('Ошибка сервера: ${response.statusCode}');
        }
      }
    } catch (e) {
      print('🔥 Исключение: $e');
      return null;
    }
  }
}
