import 'dart:convert';

import 'package:barber_booking_app/config/api_config.dart';
import 'package:barber_booking_app/models/user_models/responses/auth_response.dart';
import 'package:http/http.dart' as http;

class RefreshAccessTokenService {
  RefreshAccessTokenService._();

  static Future<bool?> isRefreshTokenRevoked(String refreshToken) async {
    try {
      final uri = Uri.parse(
        '$kApiBaseUrl/api/RefreshTokens/IsRevokedRefreshToken?token=${Uri.encodeQueryComponent(refreshToken)}',
      );
      final res = await http.get(uri).timeout(const Duration(seconds: 12));
      if (res.statusCode != 200) return null;
      final decoded = json.decode(res.body);
      if (decoded is bool) return decoded;
      return null;
    } catch (_) {
      return null;
    }
  }

  static Future<AuthResponse?> refreshAccessToken(
    String refreshToken,
    String devices,
  ) async {
    try {
      final uri = Uri.parse('$kApiBaseUrl/api/RefreshTokens/RefreshAccessToken');
      final res = await http
          .post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'refreshToken': refreshToken,
          'devices': devices,
        }),
      )
          .timeout(const Duration(seconds: 15));
      if (res.statusCode != 200) return null;
      final map = json.decode(res.body);
      if (map is! Map<String, dynamic>) return null;
      return AuthResponse.fromJson(Map<String, dynamic>.from(map));
    } catch (_) {
      return null;
    }
  }
}
