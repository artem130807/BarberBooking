import 'package:url_launcher/url_launcher.dart';

/// Оставляет цифры и один ведущий «+» для tel:-ссылки.
String? sanitizePhoneForTel(String raw) {
  final s = raw.trim();
  if (s.isEmpty) return null;
  final buf = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    final c = s[i];
    if (c == '+' && buf.isEmpty) {
      buf.write(c);
    } else if (RegExp(r'\d').hasMatch(c)) {
      buf.write(c);
    }
  }
  final out = buf.toString();
  if (out.isEmpty || out == '+') return null;
  return out;
}

/// Открывает системный набор номера (звонок клиенту).
Future<bool> launchPhoneDialer(String raw) async {
  final sanitized = sanitizePhoneForTel(raw);
  if (sanitized == null) return false;
  final uri = Uri.parse('tel:$sanitized');
  return launchUrl(uri, mode: LaunchMode.externalApplication);
}
