import 'dart:convert';

import 'package:barber_booking_app/config/api_config.dart';
import 'package:barber_booking_app/models/master_interface_models/response/get_master_appointments_short_response.dart';
import 'package:http/http.dart' as http;

class MasterAppointmentsListService {
  Future<List<GetMasterAppointmentsShortResponse>> fetchAll(String? token) async {
    if (token == null || token.isEmpty) return [];
    try {
      final url = Uri.parse(
        '$kApiBaseUrl/api/Appointment/get-appointmentsByMasterId',
      );
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode != 200) return [];
      final decoded = json.decode(response.body);
      if (decoded is! List) return [];
      return decoded
          .map((e) => GetMasterAppointmentsShortResponse.fromJson(
                Map<String, dynamic>.from(e as Map),
              ))
          .toList();
    } catch (_) {
      return [];
    }
  }
}
