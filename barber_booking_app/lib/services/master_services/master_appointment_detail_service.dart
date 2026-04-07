import 'dart:convert';

import 'package:barber_booking_app/config/api_config.dart';
import 'package:barber_booking_app/models/master_interface_models/response/get_master_appointment_info_response.dart';
import 'package:http/http.dart' as http;

class MasterAppointmentDetailService {
  Future<GetMasterAppointmentInfoResponse?> fetchById({
    required String? token,
    required String appointmentId,
  }) async {
    if (token == null || token.isEmpty) return null;
    try {
      final url = Uri.parse(
        '$kApiBaseUrl/api/Appointment/get-appointmentMasterById$appointmentId',
      );
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode != 200) return null;
      final map = json.decode(response.body) as Map<String, dynamic>;
      return GetMasterAppointmentInfoResponse.fromJson(map);
    } catch (_) {
      return null;
    }
  }


  Future<({bool ok, String? errorMessage})> completeAppointment({
    required String? token,
    required String appointmentId,
  }) async {
    if (token == null || token.isEmpty) {
      return (ok: false, errorMessage: 'Нет авторизации');
    }
    try {
      final url = Uri.parse(
        '$kApiBaseUrl/api/Appointment/completed-appointment/$appointmentId',
      );
      final response = await http.patch(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        return (ok: true, errorMessage: null);
      }
      final body = response.body;
      if (body.isNotEmpty) {
        try {
          final decoded = json.decode(body);
          if (decoded is String) {
            return (ok: false, errorMessage: decoded);
          }
          if (decoded is Map && decoded['error'] != null) {
            return (ok: false, errorMessage: decoded['error'].toString());
          }
        } catch (_) {}
        return (ok: false, errorMessage: body);
      }
      return (ok: false, errorMessage: 'Ошибка ${response.statusCode}');
    } catch (_) {
      return (ok: false, errorMessage: 'Нет соединения с сервером');
    }
  }

  Future<bool> cancelAppointment({
    required String? token,
    required String appointmentId,
  }) async {
    if (token == null || token.isEmpty) return false;
    try {
      final url = Uri.parse(
        '$kApiBaseUrl/api/Appointment/delete-appointment/$appointmentId',
      );
      final response = await http.patch(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}
