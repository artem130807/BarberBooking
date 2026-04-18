import 'dart:convert';

import 'package:barber_booking_app/config/api_config.dart';
import 'package:barber_booking_app/models/params/page_params.dart';
import 'package:barber_booking_app/models/salon_models/response/get_salons_response.dart';
import 'package:barber_booking_app/services/auth_services/auth_http_headers.dart';
import 'package:http/http.dart' as http;

class GetSalonsByServiceService {
  Future<List<GetSalonsResponse>?> getSalonsByServiceName(
    String? serviceName,
    PageParams params,
  ) async {
    try {
      final name = (serviceName ?? '').trim();
      if (name.isEmpty) {
        return null;
      }
      final page = params.Page ?? 1;
      final pageSize = params.PageSize ?? 20;

      final headers = await AuthHttpHeaders.jsonWithOptionalBearer();

      final url =
          Uri.parse('$kApiBaseUrl/api/Salon/GetSalonsByServiceName').replace(
        queryParameters: <String, String>{
          'serviceName': name,
          'Page': '$page',
          'PageSize': '$pageSize',
        },
      );

      final response = await http.get(
        url,
        headers: headers,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse =
            json.decode(response.body) as Map<String, dynamic>;
        final data = jsonResponse['data'] ?? jsonResponse['Data'];
        if (data is! List<dynamic>) {
          return [];
        }
        if (data.isEmpty) {
          return [];
        }
        return data
            .map((e) =>
                GetSalonsResponse.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList();
      }

      try {
        final errorJson = json.decode(response.body) as Map<String, dynamic>?;
        throw Exception(errorJson?['error'] ?? 'Неизвестная ошибка');
      } catch (_) {
        throw Exception('Ошибка сервера: ${response.statusCode}');
      }
    } catch (_) {
      return null;
    }
  }
}
