import 'dart:convert';

import 'package:barber_booking_app/config/api_config.dart';
import 'package:barber_booking_app/models/appointment_models/request/create_appointment_request.dart';
import 'package:barber_booking_app/services/auth_services/auth_http_headers.dart';
import 'package:http/http.dart' as http;

class CreateAppointmentService {
  Future<bool> createAppointment(CreateAppointmentRequest? request) async {
    if (request == null) {
      return false;
    }
    final headers = await AuthHttpHeaders.bearerJson();
    if (headers == null) {
      return false;
    }

    try {
      final url = Uri.parse('$kApiBaseUrl/api/Appointment/create-appointment');
      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(request.toJson()),
      );
      print('📥 Статус: ${response.statusCode}');
      print('📥 Ответ: ${response.body}');

      if (response.statusCode == 200) {
        return true;
      } else {
        print('❌ Ошибка сервера: ${response.body}');
        return false;
      }
    } catch (e) {
      print(e);
      return false;
    }
  }
}
