String salonWorkingHoursLabel(String? openingTime, String? closingTime) {
  final o = openingTime?.trim();
  final c = closingTime?.trim();
  if (o == null || c == null || o.isEmpty || c.isEmpty) {
    return 'По записи';
  }
  return '${_formatTimeForDisplay(o)} — ${_formatTimeForDisplay(c)}';
}

String _formatTimeForDisplay(String raw) {
  final t = raw.trim();
  if (t.length >= 8 && t[2] == ':' && t[5] == ':') {
    return t.substring(0, 5);
  }
  if (t.length >= 5 && t[2] == ':') {
    return t.substring(0, 5);
  }
  return t;
}
