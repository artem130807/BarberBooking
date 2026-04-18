import 'dart:convert';

import 'package:barber_booking_app/config/api_config.dart';
import 'package:barber_booking_app/models/salon_models/response/salon_admin_stats_response.dart';
import 'package:barber_booking_app/services/auth_services/auth_http_headers.dart';
import 'package:http/http.dart' as http;

class GetSalonAdminStatsService {
  Future<SalonAdminStatsResponse?> getStats(String salonId) async {
    try {
      final headers = await AuthHttpHeaders.bearerJson();
      if (headers == null) return null;

      final url =
          Uri.parse('$kApiBaseUrl/api/Salon/GetSalonAdminStats/$salonId');
      final response = await http.get(
        url,
        headers: headers,
      );
      if (response.statusCode == 200) {
        final map = json.decode(response.body) as Map<String, dynamic>;
        return SalonAdminStatsResponse.fromJson(map);
      }
      return null;
    } catch (_) {
      return null;
    }
  }
}
