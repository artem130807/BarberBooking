import 'dart:convert';

class JwtExpiry {
  JwtExpiry._();

  static const Duration defaultSkew = Duration(seconds: 45);

  static bool isAccessTokenExpired(String jwt, {Duration skew = defaultSkew}) {
    final exp = _readExpUtc(jwt);
    if (exp == null) return false;
    final now = DateTime.now().toUtc();
    return !now.isBefore(exp.subtract(skew));
  }

  static DateTime? _readExpUtc(String jwt) {
    final parts = jwt.split('.');
    if (parts.length != 3) return null;
    try {
      var payload = parts[1].replaceAll('-', '+').replaceAll('_', '/');
      final mod = payload.length % 4;
      if (mod > 0) {
        payload += '=' * (4 - mod);
      }
      final decoded = utf8.decode(base64.decode(payload));
      final map = json.decode(decoded);
      if (map is! Map<String, dynamic>) return null;
      final exp = map['exp'];
      if (exp == null) return null;
      final sec = exp is int ? exp : int.tryParse(exp.toString());
      if (sec == null) return null;
      return DateTime.fromMillisecondsSinceEpoch(sec * 1000, isUtc: true);
    } catch (_) {
      return null;
    }
  }
}
