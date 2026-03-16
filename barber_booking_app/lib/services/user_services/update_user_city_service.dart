import 'dart:convert';

import 'package:barber_booking_app/models/user_models/responses/update_city_response.dart';
import 'package:http/http.dart' as http;

class UpdateUserCityService {
  final String baseUrl = 'http://192.168.0.100:5088';

  /// Возвращает новый город и новый токен (с обновлённым городом). Токен нужно сохранить в AuthProvider.
  Future<UpdateCityResponse?> updateCity(String? token, String city) async {
    if (token == null || token.isEmpty || city.trim().isEmpty) return null;
    try {
      final url = Uri.parse('$baseUrl/api/Users/updateCity').replace(
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
        final newCity = decoded['city'] as String? ?? decoded['City'] as String? ?? city.trim();
        final newToken = decoded['token'] as String? ?? decoded['Token'] as String?;
        return UpdateCityResponse(city: newCity, token: newToken);
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
