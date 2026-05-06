import 'dart:convert';

import 'package:barber_booking_app/config/api_config.dart';
import 'package:barber_booking_app/services/auth_services/auth_http_headers.dart';
import 'package:http/http.dart' as http;

class FcmTokenRegistrationService {
  FcmTokenRegistrationService._();

  static final Uri _endpoint =
      Uri.parse('$kApiBaseUrl/api/PushNotifications/fcm-token');

  static Future<bool?> register(String token) async {
    if (token.isEmpty) return false;
    try {
      final headers = await AuthHttpHeaders.bearerJson();
      if (headers == null) return null;
      final res = await http
          .post(
        _endpoint,
        headers: headers,
        body: json.encode({'token': token}),
      )
          .timeout(const Duration(seconds: 15));
      return res.statusCode == 200;
    } catch (_) {
      return null;
    }
  }

  /// [bearerAccessToken] — при вызове из [AuthProvider.logout] во время refresh
  /// нельзя ждать [AuthHttpHeaders.bearerJson] (deadlock на `_refreshInFlight`).
  static Future<bool?> unregister(
    String token, {
    String? bearerAccessToken,
  }) async {
    if (token.isEmpty) return false;
    try {
      Map<String, String>? headers;
      if (bearerAccessToken != null && bearerAccessToken.isNotEmpty) {
        headers = {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $bearerAccessToken',
        };
      } else {
        headers = await AuthHttpHeaders.bearerJson();
      }
      if (headers == null) return null;
      final res = await http
          .delete(
        _endpoint,
        headers: headers,
        body: json.encode({'token': token}),
      )
          .timeout(const Duration(seconds: 15));
      return res.statusCode == 200;
    } catch (_) {
      return null;
    }
  }
}
