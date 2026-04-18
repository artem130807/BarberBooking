import 'dart:convert';

import 'package:barber_booking_app/config/api_config.dart';
import 'package:barber_booking_app/models/salon_models/response/get_salon_admin_response.dart';
import 'package:barber_booking_app/services/auth_services/auth_session_binding.dart';
import 'package:http/http.dart' as http;

class GetSalonsAdminService {
  Future<List<GetSalonAdminResponse>?> getSalonsAdmin() async {
    try {
      final token = await AuthSessionBinding.instance.accessToken();
      final url = Uri.parse('$kApiBaseUrl/api/SalonAdmin/GetSalonsAdmin');
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          if (token != null && token.isNotEmpty)
            'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode != 200) return null;
      final decoded = json.decode(response.body);
      if (decoded is! List<dynamic>) return null;
      return decoded
          .map(
            (e) => GetSalonAdminResponse.fromJson(
              Map<String, dynamic>.from(e as Map),
            ),
          )
          .toList();
    } catch (_) {
      return null;
    }
  }
}
