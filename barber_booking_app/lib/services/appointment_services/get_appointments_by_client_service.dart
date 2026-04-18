import 'dart:convert';

import 'package:barber_booking_app/config/api_config.dart';
import 'package:barber_booking_app/models/appointment_models/response/get_appointments_by_client_response.dart';
import 'package:barber_booking_app/services/auth_services/auth_http_headers.dart';
import 'package:http/http.dart' as http;

class GetAppointmentsByClientService {
  Future<List<GetAppointmentsByClientResponse>?> getAppointments() async {
    try {
      final headers = await AuthHttpHeaders.bearerJson();
      if (headers == null) return null;

      final url = Uri.parse(
        '$kApiBaseUrl/api/Appointment/get-appointmentsByClientId',
      );

      final response = await http.get(url, headers: headers);

      print('📥 Статус: ${response.statusCode}');
      print('📥 Ответ: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        print('📊 Количество записей: ${jsonList.length}');
        if (jsonList.isEmpty) {
          print('⚠️ Сервер вернул пустой список');
          return [];
        }
        return jsonList
            .map((json) => GetAppointmentsByClientResponse.fromJson(json))
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
