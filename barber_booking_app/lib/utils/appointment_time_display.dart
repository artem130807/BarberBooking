import 'package:intl/intl.dart';

String formatAppointmentSlotTime(String? startTime) {
  if (startTime == null || startTime.isEmpty) {
    return '—';
  }
  final t = startTime.trim();
  final parsed = DateTime.tryParse(t);
  if (parsed != null) {
    return DateFormat('HH:mm').format(parsed.toLocal());
  }
  final re = RegExp(r'^(\d{1,2}):(\d{2})');
  final m = re.firstMatch(t);
  if (m != null) {
    final h = m.group(1)!.padLeft(2, '0');
    final min = m.group(2)!;
    return '$h:$min';
  }
  return t;
}
