import 'dart:convert';

import 'package:barber_booking_app/config/api_config.dart';
import 'package:barber_booking_app/models/service_models/response/get_service_search_response.dart';
import 'package:barber_booking_app/services/auth_services/auth_http_headers.dart';
import 'package:http/http.dart' as http;

class GetServiceSearchService {
  Future<List<GetServiceSearchResponse>?> getServices() async {
    try {
      final headers = await AuthHttpHeaders.jsonWithOptionalBearer();
      final url = Uri.parse('$kApiBaseUrl/api/Services/get-services-by-startWith');
      final response = await http.get(
        url,
        headers: headers,
      );
      print('📥 Статус: ${response.statusCode}');
      print('📥 Ответ: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        final raw = jsonResponse['data'] ?? jsonResponse['Data'];
        if (raw is! List<dynamic>) {
          return [];
        }
        print('📊 Количество услуг: ${raw.length}');
        if (raw.isEmpty) {
          print('⚠️ Сервер вернул пустой список');
          return [];
        }
        return raw
            .map((json) => GetServiceSearchResponse.fromJson(
                  json as Map<String, dynamic>,
                ))
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
