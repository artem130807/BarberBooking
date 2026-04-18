import 'dart:convert';

import 'package:barber_booking_app/config/api_config.dart';
import 'package:barber_booking_app/models/appointment_models/response/get_appointment_awaiting_review_response.dart';
import 'package:barber_booking_app/models/params/page_params.dart';
import 'package:barber_booking_app/services/auth_services/auth_http_headers.dart';
import 'package:http/http.dart' as http;

class GetAppointmentAwaitingReviewService {
  Future<List<GetAppointmentAwaitingReviewResponse>?> getAppointments(
    PageParams pageParams,
  ) async {
    try {
      final headers = await AuthHttpHeaders.bearerJson();
      if (headers == null) return null;

      final url = Uri.parse(
        '$kApiBaseUrl/api/Appointment/GetAppointmentsAwaitingReview',
      ).replace(
        queryParameters: {
          'page': pageParams.Page.toString(),
          'pageSize': pageParams.PageSize.toString(),
        },
      );

      final response = await http.get(url, headers: headers);

      print('📥 Статус: ${response.statusCode}');
      print('📥 Ответ: ${response.body}');

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        final List<dynamic> jsonList = decoded is Map<String, dynamic> &&
                (decoded).containsKey('data')
            ? (decoded as Map<String, dynamic>)['data'] as List<dynamic>
            : decoded is List<dynamic>
                ? decoded as List<dynamic>
                : [];
        print('📊 Количество ожидающих отзыв: ${jsonList.length}');
        if (jsonList.isEmpty) {
          print('⚠️ Сервер вернул пустой список');
          return [];
        }
        return jsonList
            .map((json) => GetAppointmentAwaitingReviewResponse.fromJson(
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
