import 'dart:convert';

import 'package:barber_booking_app/config/api_config.dart';
import 'package:barber_booking_app/models/master_interface_models/master_appointment_query_filter.dart';
import 'package:barber_booking_app/models/master_interface_models/response/get_master_appointments_short_response.dart';
import 'package:barber_booking_app/models/master_interface_models/response/paged_master_appointments_result.dart';
import 'package:http/http.dart' as http;

class MasterAppointmentsListService {
  Future<PagedMasterAppointmentsResult?> fetchPage({
    required String? token,
    MasterAppointmentQueryFilter? filter,
    int page = 1,
    int pageSize = 50,
  }) async {
    if (token == null || token.isEmpty) return null;
    try {
      final q = <String, String>{
        'Page': '$page',
        'PageSize': '$pageSize',
      };
      if (filter != null) {
        q.addAll(filter.toQueryMap());
      }
      final url = Uri.parse(
        '$kApiBaseUrl/api/Appointment/get-appointmentsByMasterId',
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
