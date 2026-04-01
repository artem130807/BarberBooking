/// Соответствует [FilterAppointments] на API (статус, период, пресеты день/неделя).
class FilterAppointmentsParams {
  const FilterAppointmentsParams({
    this.confirmed,
    this.completed,
    this.cancelled,
    this.thisWeek,
    this.thisDay,
    this.from,
    this.to,
  });

  final bool? confirmed;
  final bool? completed;
  final bool? cancelled;
  final bool? thisWeek;
  final bool? thisDay;
  final DateTime? from;
  final DateTime? to;

  static FilterAppointmentsParams awaiting() =>
      const FilterAppointmentsParams(confirmed: true);

  static FilterAppointmentsParams done() =>
      const FilterAppointmentsParams(completed: true);

  static FilterAppointmentsParams cancelledOnly() =>
      const FilterAppointmentsParams(cancelled: true);

  /// Параметры для query string (`[FromQuery] FilterAppointments` на API).
  Map<String, String> toQueryMap() {
    final m = <String, String>{};
    if (confirmed == true) m['Confirmed'] = 'true';
    if (completed == true) m['Completed'] = 'true';
    if (cancelled == true) m['Cancelled'] = 'true';
    if (thisWeek == true) m['ThisWeek'] = 'true';
    if (thisDay == true) m['ThisDay'] = 'true';
    if (from != null) m['from'] = from!.toUtc().toIso8601String();
    if (to != null) m['to'] = to!.toUtc().toIso8601String();
    return m;
  }
}
