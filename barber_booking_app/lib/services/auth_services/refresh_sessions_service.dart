import 'dart:convert';

import 'package:barber_booking_app/config/api_config.dart';
import 'package:barber_booking_app/models/auth_models/refresh_token_session.dart';
import 'package:barber_booking_app/services/auth_services/auth_http_headers.dart';
import 'package:http/http.dart' as http;

class RefreshSessionsService {
  Future<List<RefreshTokenSession>?> listSessions({String? forUserId}) async {
    try {
      final headers = await AuthHttpHeaders.bearerJson();
      if (headers == null) return null;
      final uri = forUserId != null && forUserId.isNotEmpty
          ? Uri.parse(
              '$kApiBaseUrl/api/RefreshTokens/GetRefreshTokensForUser/$forUserId',
            )
          : Uri.parse('$kApiBaseUrl/api/RefreshTokens/GetRefreshTokens');
      final res = await http.get(uri, headers: headers);
      if (res.statusCode != 200) return null;
      final decoded = json.decode(res.body);
      if (decoded is! List) return null;
      return decoded
          .map((e) => RefreshTokenSession.fromJson(
                Map<String, dynamic>.from(e as Map),
              ))
          .toList();
    } catch (_) {
      return null;
    }
  }

  Future<bool?> revokeSession(String sessionId) async {
    try {
      final headers = await AuthHttpHeaders.bearerJson();
      if (headers == null) return null;
      final uri = Uri.parse(
        '$kApiBaseUrl/api/RefreshTokens/RevokedRefreshToken/$sessionId',
      );
      final res = await http.patch(uri, headers: headers);
      return res.statusCode == 200;
    } catch (_) {
      return null;
    }
  }

  Future<bool?> revokeAllOwnSessions() async {
    try {
      final headers = await AuthHttpHeaders.bearerJson();
      if (headers == null) return null;
      final uri =
          Uri.parse('$kApiBaseUrl/api/RefreshTokens/RevokedRefreshTokens');
      final res = await http.patch(uri, headers: headers);
      return res.statusCode == 200;
    } catch (_) {
      return null;
    }
  }

  Future<bool?> revokeAllSessionsForUser(String userId) async {
    try {
      final headers = await AuthHttpHeaders.bearerJson();
      if (headers == null) return null;
      final uri = Uri.parse(
        '$kApiBaseUrl/api/RefreshTokens/RevokedRefreshTokensForUser/$userId',
      );
      final res = await http.patch(uri, headers: headers);
      return res.statusCode == 200;
    } catch (_) {
      return null;
    }
  }
}
