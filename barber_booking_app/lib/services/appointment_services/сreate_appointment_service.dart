import 'dart:convert';

import 'package:barber_booking_app/config/api_config.dart';
import 'package:barber_booking_app/models/appointment_models/request/create_appointment_request.dart';
import 'package:http/http.dart' as http;

typedef CreateAppointmentOutcome = ({bool ok, String? errorMessage});

class CreateAppointmentService {
  static const Duration _requestTimeout = Duration(seconds: 30);

  Future<CreateAppointmentOutcome> createAppointment(
      CreateAppointmentRequest? request, String? token) async {
    if (request == null || token == null || token.isEmpty) {
      return (ok: false, errorMessage: 'Не переданы данные записи или токен авторизации');
    }

    try {
      final root = kApiBaseUrl.endsWith('/')
          ? kApiBaseUrl.substring(0, kApiBaseUrl.length - 1)
          : kApiBaseUrl;
      final url = Uri.parse('$root/api/Appointment/create-appointment');
      final response = await http
          .post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(request.toJson()),
      )
          .timeout(_requestTimeout);
      if (response.statusCode == 200) {
        return (ok: true, errorMessage: null);
      }
      final detail = response.body.isNotEmpty
          ? response.body
          : 'Код ответа: ${response.statusCode}';
      return (ok: false, errorMessage: detail);
    } catch (e) {
      return (ok: false, errorMessage: e.toString());
    }
  }
}
