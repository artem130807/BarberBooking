import 'dart:convert';
import 'package:barber_booking_app/models/salon_models/response/salon_admin_stats_response.dart';
import 'package:http/http.dart' as http;
import 'package:barber_booking_app/config/api_config.dart';

class GetSalonAdminStatsService {

  Future<SalonAdminStatsResponse?> getStats(String salonId, String? token) async {
    try {
      final url = Uri.parse('$kApiBaseUrl/api/Salon/GetSalonAdminStats/$salonId');
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          if (token != null && token.isNotEmpty)
            'Authorization': 'Bearer $token',
        },
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
