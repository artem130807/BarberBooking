import 'dart:convert';

import 'package:barber_booking_app/config/api_config.dart';
import 'package:barber_booking_app/models/appointment_models/request/create_appointment_request.dart';
import 'package:barber_booking_app/models/master_interface_models/response/master_service_for_booking.dart';
import 'package:barber_booking_app/services/auth_services/auth_http_headers.dart';
import 'package:http/http.dart' as http;

class MasterManualBookingService {
  Future<List<MasterServiceForBooking>?> fetchServicesForBooking({
    required String masterProfileId,
  }) async {
    final headers = await AuthHttpHeaders.bearerJson();
    if (headers == null || masterProfileId.isEmpty) {
      return null;
    }
    try {
      final url = Uri.parse(
        '$kApiBaseUrl/api/MasterServices/get-services-for-booking-by-master/$masterProfileId',
      );
      final response = await http.get(
        url,
        headers: headers,
      );
      if (response.statusCode != 200) {
        return null;
      }
      final decoded = json.decode(response.body);
      if (decoded is! List) {
        return null;
      }
      return decoded
          .map((e) => MasterServiceForBooking.fromJson(
                Map<String, dynamic>.from(e as Map),
              ))
          .where((e) => e.id.isNotEmpty)
          .toList();
    } catch (_) {
      return null;
    }
  }

  Future<String?> createWithoutAppUser({
    required CreateAppointmentRequest request,
  }) async {
    final headers = await AuthHttpHeaders.bearerJson();
    if (headers == null || request.SalonId == null) {
      return 'Нужна авторизация';
    }
    try {
      final url = Uri.parse(
        '$kApiBaseUrl/api/Appointment/create-appointment-without-user',
      );
      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(request.toJson()),
      );
      if (response.statusCode == 200) {
        return null;
      }
      final raw = response.body;
      if (raw.isEmpty) {
        return 'Ошибка ${response.statusCode}';
      }
      try {
        final j = json.decode(raw);
        if (j is Map && j['error'] != null) {
          return j['error'].toString();
        }
      } catch (_) {}
      return raw.length > 200 ? 'Ошибка ${response.statusCode}' : raw;
    } catch (_) {
      return 'Ошибка сети';
    }
  }
}
