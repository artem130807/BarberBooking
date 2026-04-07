import 'dart:convert';

import 'package:barber_booking_app/config/api_config.dart';
import 'package:barber_booking_app/models/master_interface_models/slot_appointment_status_filter.dart';
import 'package:barber_booking_app/models/master_interface_models/response/get_master_appointments_short_response.dart';
import 'package:barber_booking_app/models/master_interface_models/response/paged_master_appointments_result.dart';
import 'package:http/http.dart' as http;

class MasterSlotAppointmentsService {
  Future<PagedMasterAppointmentsResult?> fetchByTimeSlot({
    required String? token,
    required String timeSlotId,
    int page = 1,
    int pageSize = 100,
    SlotAppointmentStatusFilter? statusFilter,
  }) async {
    if (token == null || token.isEmpty || timeSlotId.isEmpty) return null;
    try {
      final q = <String, String>{
        'Page': '$page',
        'PageSize': '$pageSize',
      };
      if (statusFilter != null) {
        q.addAll(statusFilter.toQueryMap());
      }
      final url = Uri.parse(
        '$kApiBaseUrl/api/Appointment/get-appointments-by-timeSlot/$timeSlotId',
      ).replace(queryParameters: q);
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode != 200) return null;
      final decoded = json.decode(response.body);
      if (decoded is! Map<String, dynamic>) return null;
      final rawList = decoded['data'] ?? decoded['Data'];
      if (rawList is! List) {
        return PagedMasterAppointmentsResult(data: [], count: 0);
      }
      final list = rawList
          .map((e) => GetMasterAppointmentsShortResponse.fromJson(
                Map<String, dynamic>.from(e as Map),
              ))
          .toList();
      final countRaw = decoded['count'] ?? decoded['Count'];
      final count = countRaw is int
          ? countRaw
          : int.tryParse(countRaw?.toString() ?? '') ?? list.length;
      return PagedMasterAppointmentsResult(data: list, count: count);
    } catch (_) {
      return null;
    }
  }
}
