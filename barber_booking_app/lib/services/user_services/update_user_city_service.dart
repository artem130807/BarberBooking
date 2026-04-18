import 'dart:convert';

import 'package:barber_booking_app/config/api_config.dart';
import 'package:barber_booking_app/models/user_models/responses/update_city_response.dart';
import 'package:barber_booking_app/services/auth_services/auth_session_binding.dart';
import 'package:http/http.dart' as http;

class UpdateUserCityService {
  Future<UpdateCityResponse?> updateCity(String city) async {
    final token = await AuthSessionBinding.instance.accessToken();
    if (token == null || token.isEmpty || city.trim().isEmpty) return null;
    try {
      final url = Uri.parse('$kApiBaseUrl/api/Users/updateCity').replace(
        queryParameters: {'city': city.trim()},
      );
      final response = await http.patch(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        final body = response.body;
        if (body.isEmpty) return UpdateCityResponse(city: city.trim());
        final decoded = json.decode(body) as Map<String, dynamic>?;
        if (decoded == null) return UpdateCityResponse(city: city.trim());
        final newCity = decoded['city'] as String? ??
            decoded['City'] as String? ??
            city.trim();
        final newToken = decoded['token'] as String? ?? decoded['Token'] as String?;
        return UpdateCityResponse(city: newCity, token: newToken);
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
