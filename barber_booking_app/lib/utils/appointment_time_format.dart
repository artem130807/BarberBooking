String formatAppointmentTimeHm(String? raw) {
  if (raw == null || raw.isEmpty) return '—';
  final t = raw.trim();
  final parts = t.split(':');
  if (parts.length >= 2) {
    final h = parts[0].padLeft(2, '0');
    final m = parts[1].padLeft(2, '0');
    return '$h:$m';
  }
  return t;
}
