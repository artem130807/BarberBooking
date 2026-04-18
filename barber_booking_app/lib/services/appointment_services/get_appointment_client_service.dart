import 'dart:convert';

import 'package:barber_booking_app/config/api_config.dart';
import 'package:barber_booking_app/models/appointment_models/response/get_appointment_client_response.dart';
import 'package:barber_booking_app/services/auth_services/auth_http_headers.dart';
import 'package:http/http.dart' as http;

class GetAppointmentClientService {
  Future<GetAppointmentClientResponse?> getAppointmentById(
    String appointmentId,
  ) async {
    try {
      final headers = await AuthHttpHeaders.bearerJson();
      if (headers == null) return null;

      final url = Uri.parse(
        '$kApiBaseUrl/api/Appointment/get-appointmentClientById/$appointmentId',
      );

      final response = await http.get(url, headers: headers);

      print('📥 Статус: ${response.statusCode}');
      print('📥 Ответ: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        return GetAppointmentClientResponse.fromJson(jsonData);
      } else {
        print('❌ Ошибка сервера: ${response.body}');
        throw Exception('Ошибка сервера: ${response.statusCode}');
      }
    } catch (e) {
      print('🔥 Исключение: $e');
      return null;
    }
  }
}
