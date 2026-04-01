import 'dart:convert';
import 'package:barber_booking_app/models/appointment_models/response/salon_appointment_admin_response.dart';
import 'package:barber_booking_app/models/params/appointment_params/filter_appointments_params.dart';
import 'package:barber_booking_app/models/params/page_params.dart';
import 'package:http/http.dart' as http;
import 'package:barber_booking_app/config/api_config.dart';

class GetSalonAppointmentsAdminService {
  Future<Map<String, dynamic>?> getPaged(
    String salonId,
    PageParams params,
    String? token, {
    FilterAppointmentsParams? filter,
  }) async {
    try {
      final qp = <String, String>{
        'page': params.Page.toString(),
        'pageSize': params.PageSize.toString(),
      };
      if (filter != null) qp.addAll(filter.toQueryMap());
      final url = Uri.parse(
        '$kApiBaseUrl/api/Appointment/get-salon-appointments-paged/$salonId',
      ).replace(queryParameters: qp);
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      }
      if (response.statusCode == 400) {
        final body = response.body;
        if (body.contains('пуст') ||
            body.toLowerCase().contains('empty')) {
          return {'data': <dynamic>[], 'count': 0};
        }
        try {
          final err = json.decode(body);
          if (err is Map && err['error'] != null) {
            final m = err['error'].toString().toLowerCase();
            if (m.contains('пуст') || m.contains('empty')) {
              return {'data': <dynamic>[], 'count': 0};
            }
          }
        } catch (_) {}
      }
      return null;
    } catch (e) {
      print(e);
      return null;
    }
  }

  List<SalonAppointmentAdminResponse>? parseData(Map<String, dynamic> json) {
    final raw = json['data'];
    if (raw is! List) return null;
    return raw
        .map((e) => SalonAppointmentAdminResponse.fromJson(
            Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  int parseCount(Map<String, dynamic> json) {
    final c = json['count'];
    if (c is int) return c;
    if (c is num) return c.toInt();
    return 0;
  }

  Future<List<SalonAppointmentAdminResponse>> fetchAllPages(
    String salonId,
    String? token, {
    FilterAppointmentsParams? filter,
    int pageSize = 100,
  }) async {
    final all = <SalonAppointmentAdminResponse>[];
    var page = 1;
    while (true) {
      final map = await getPaged(
        salonId,
        PageParams(Page: page, PageSize: pageSize),
        token,
        filter: filter,
      );
      if (map == null) break;
      final chunk = parseData(map) ?? [];
      all.addAll(chunk);
      if (chunk.length < pageSize) break;
      page++;
    }
    return all;
  }

}
