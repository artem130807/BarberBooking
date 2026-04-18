import 'package:barber_booking_app/services/auth_services/auth_session_binding.dart';

class AuthHttpHeaders {
  AuthHttpHeaders._();

  static Future<Map<String, String>?> bearerJson() async {
    final t = await AuthSessionBinding.instance.accessToken();
    if (t == null || t.isEmpty) return null;
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $t',
    };
  }

  static Future<Map<String, String>> jsonWithOptionalBearer() async {
    final t = await AuthSessionBinding.instance.accessToken();
    final m = <String, String>{'Content-Type': 'application/json'};
    if (t != null && t.isNotEmpty) {
      m['Authorization'] = 'Bearer $t';
    }
    return m;
  }

  /// Только заголовок авторизации (для `MultipartRequest`, без `Content-Type`).
  static Future<Map<String, String>?> bearerAuthOnly() async {
    final t = await AuthSessionBinding.instance.accessToken();
    if (t == null || t.isEmpty) return null;
    return {'Authorization': 'Bearer $t'};
  }
}
