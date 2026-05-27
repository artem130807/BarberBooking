import 'dart:convert';

import 'package:barber_booking_app/navigation/role_routes.dart';

/// Роль для маршрутизации: если API не отдал [roleInterface], читаем из JWT (как на бэкенде).
abstract final class JwtRoleInfer {
  static int? inferRoleInterface(String jwt) {
    final payload = _decodePayloadMap(jwt);
    if (payload == null) return null;
    final roles = _collectRoleStrings(payload);
    if (roles.isEmpty) return null;

    bool has(String pattern) =>
        roles.any((r) => _norm(r).contains(_norm(pattern)));

    if (roles.any((r) => _equivRole(r, 'Admin'))) return RoleRoutes.adminRole;
    if (roles.any((r) => _equivRole(r, 'Master'))) return RoleRoutes.masterRole;
    if (roles.any((r) => _equivRole(r, 'User'))) return RoleRoutes.userRole;

    if (has('admin')) return RoleRoutes.adminRole;
    if (has('master')) return RoleRoutes.masterRole;
    return RoleRoutes.userRole;
  }

  static Map<String, dynamic>? _decodePayloadMap(String jwt) {
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
      if (json is Map<String, dynamic>) return json;
    } catch (_) {}
    return null;
  }

  static List<String> _collectRoleStrings(Map<String, dynamic> payload) {
    const keys = [
      'role',
      'roles',
      'http://schemas.microsoft.com/ws/2008/06/identity/claims/role',
    ];
    final out = <String>[];
    for (final k in keys) {
      final v = payload[k];
      if (v == null) continue;
      if (v is String && v.isNotEmpty) out.add(v);
      if (v is List) {
        for (final e in v) {
          if (e != null && e.toString().isNotEmpty) out.add(e.toString());
        }
      }
    }
    return out;
  }

  static String _norm(String s) => s.toLowerCase().trim();

  static bool _equivRole(String raw, String canonical) {
    final r = raw.trim().toLowerCase();
    final c = canonical.toLowerCase();
    if (r == c) return true;
    final tail = raw.split(RegExp(r'[/:]')).last.trim().toLowerCase();
    return tail == c;
  }
}
