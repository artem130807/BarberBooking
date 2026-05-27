import 'dart:convert';

abstract final class JwtClaims {
  static String? displayNameFromToken(String? jwt) {
    final payload = _decodePayloadMap(jwt);
    if (payload == null) return null;

    const keys = [
      'name',
      'unique_name',
      'http://schemas.xmlsoap.org/ws/2005/05/identity/claims/name',
    ];

    for (final key in keys) {
      final value = payload[key]?.toString().trim();
      if (value != null && value.isNotEmpty) return value;
    }
    return null;
  }

  static String? userIdFromToken(String? jwt) {
    final payload = _decodePayloadMap(jwt);
    if (payload == null) return null;

    const keys = [
      'userId',
      'nameid',
      'sub',
      'http://schemas.xmlsoap.org/ws/2005/05/identity/claims/nameidentifier',
    ];

    for (final key in keys) {
      final value = payload[key]?.toString().trim();
      if (value != null && value.isNotEmpty) return value;
    }
    return null;
  }

  static Map<String, dynamic>? _decodePayloadMap(String? jwt) {
    if (jwt == null || jwt.isEmpty) return null;
    final parts = jwt.split('.');
    if (parts.length != 3) return null;

    try {
      var payload = parts[1].replaceAll('-', '+').replaceAll('_', '/');
      final mod = payload.length % 4;
      if (mod > 0) {
        payload += '=' * (4 - mod);
      }
      final decoded = utf8.decode(base64.decode(payload));
      final json = jsonDecode(decoded);
      return json is Map<String, dynamic> ? json : null;
    } catch (_) {
      return null;
    }
  }
}
