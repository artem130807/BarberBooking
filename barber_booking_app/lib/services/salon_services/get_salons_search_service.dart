import 'dart:convert';

import 'package:barber_booking_app/config/api_config.dart';
import 'package:barber_booking_app/models/params/page_params.dart';
import 'package:barber_booking_app/models/salon_models/response/get_salons_response.dart';
import 'package:barber_booking_app/services/auth_services/auth_http_headers.dart';
import 'package:http/http.dart' as http;

class GetSalonsSearchService {
  Future<List<GetSalonsResponse>?> getSalons(
    String? name,
    PageParams params,
  ) async {
    try {
      final headers = await AuthHttpHeaders.jsonWithOptionalBearer();

      print('📦 Получен запрос: параметры $name,${params.Page}, ${params.PageSize}');

      final url = Uri.parse('$kApiBaseUrl/api/Salon/GetSalonsName').replace(
        queryParameters: {
          'name': name ?? '',
          'page': params.Page.toString(),
          'pageSize': params.PageSize.toString(),
        },
      );
      print('🌐 URL: $url');

      final requestBody = json.encode(params.toJson());
      print('📤 Отправляю: $requestBody');

      final response = await http.get(
        url,
        headers: headers,
      );

      print('📥 Статус: ${response.statusCode}');
      print('📥 Ответ: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        print('📊 Количество салонов: ${jsonList.length}');
        if (jsonList.isEmpty) {
          print('⚠️ Сервер вернул пустой список');
          return [];
        }
        return jsonList
            .map((json) => GetSalonsResponse.fromJson(json))
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
