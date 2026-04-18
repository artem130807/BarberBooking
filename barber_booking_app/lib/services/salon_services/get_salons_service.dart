import 'dart:convert';

import 'package:barber_booking_app/config/api_config.dart';
import 'package:barber_booking_app/models/params/page_params.dart';
import 'package:barber_booking_app/models/params/salon_params/salon_filter.dart';
import 'package:barber_booking_app/models/salon_models/response/get_salons_response.dart';
import 'package:barber_booking_app/services/auth_services/auth_http_headers.dart';
import 'package:http/http.dart' as http;

class GetSalonsService {
  Future<List<GetSalonsResponse>?> getSalons(
    PageParams params,
    SalonFilter filter,
  ) async {
    try {
      final headers = await AuthHttpHeaders.jsonWithOptionalBearer();

      print('📦 Получен запрос: параметры ${params.Page}, ${params.PageSize}');

      final qp = <String, String>{
        'page': '${params.Page ?? 1}',
        'pageSize': '${params.PageSize ?? 20}',
      };
      if (filter.IsActive == true) qp['IsActive'] = 'true';
      if (filter.MaxRating == true) qp['MaxRating'] = 'true';
      if (filter.Popular == true) qp['Popular'] = 'true';
      if (filter.MinPrice == true) qp['MinPrice'] = 'true';
      final url = Uri.parse('$kApiBaseUrl/api/Salon/GetSalonsByFilter').replace(
        queryParameters: qp,
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
