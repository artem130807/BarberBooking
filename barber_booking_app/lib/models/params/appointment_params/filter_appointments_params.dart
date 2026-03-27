/// Соответствует [FilterAppointments] на API (флаги для фильтрации по статусу).
class FilterAppointmentsParams {
  const FilterAppointmentsParams({
    this.confirmed,
    this.completed,
    this.cancelled,
  });

  final bool? confirmed;
  final bool? completed;
  final bool? cancelled;

  /// Только один флаг `true` — как ожидает репозиторий (по одному статусу).
  static FilterAppointmentsParams awaiting() =>
      const FilterAppointmentsParams(confirmed: true);

  static FilterAppointmentsParams done() =>
      const FilterAppointmentsParams(completed: true);

  static FilterAppointmentsParams cancelledOnly() =>
      const FilterAppointmentsParams(cancelled: true);

  Map<String, String> toQueryMap() {
    final m = <String, String>{};
    if (confirmed == true) m['Confirmed'] = 'true';
    if (completed == true) m['Completed'] = 'true';
    if (cancelled == true) m['Cancelled'] = 'true';
    return m;
  }
}
