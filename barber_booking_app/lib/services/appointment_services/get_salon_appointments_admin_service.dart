import 'dart:convert';
import 'package:barber_booking_app/models/appointment_models/response/salon_appointment_admin_response.dart';
import 'package:barber_booking_app/models/params/page_params.dart';
import 'package:http/http.dart' as http;

class GetSalonAppointmentsAdminService {
  final String baseUrl = 'http://192.168.0.100:5088';

  Future<Map<String, dynamic>?> getPaged(
    String salonId,
    DateTime? from,
    DateTime? to,
    PageParams params,
    String? token,
  ) async {
    try {
      final qp = <String, String>{
        'page': params.Page.toString(),
        'pageSize': params.PageSize.toString(),
      };
      if (from != null) qp['from'] = from.toUtc().toIso8601String();
      if (to != null) qp['to'] = to.toUtc().toIso8601String();
      final url = Uri.parse(
        '$baseUrl/api/Appointment/get-salon-appointments-paged/$salonId',
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
}
