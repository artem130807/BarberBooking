import 'package:barber_booking_app/config/api_config.dart';

bool _shouldRewriteOrigin(Uri uri) {
  final h = uri.host.toLowerCase();
  if (h == 'localhost' || h == '127.0.0.1' || h == '::1') return true;
  return uri.path.startsWith('/uploads/');
}

String? resolveApiMediaUrl(String? raw) {
  if (raw == null) return null;
  final s = raw.trim();
  if (s.isEmpty) return null;
  final base = Uri.parse(kApiBaseUrl);
  if (s.startsWith('/')) {
    return base.resolve(s).toString();
  }
  final uri = Uri.tryParse(s);
  if (uri == null) {
    return base.resolve(s).toString();
  }
  if (!uri.hasScheme) {
    return base.resolve(s).toString();
  }
  final path = uri.path;
  if (path.isEmpty) return null;
  if (!_shouldRewriteOrigin(uri)) {
    return s;
  }
  var resolved = base.resolve(path);
  if (uri.hasQuery) {
    resolved = resolved.replace(query: uri.query);
  }
  return resolved.toString();
}
