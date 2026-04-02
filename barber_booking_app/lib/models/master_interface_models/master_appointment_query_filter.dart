class MasterAppointmentQueryFilter {
  const MasterAppointmentQueryFilter({
    this.confirmed,
    this.completed,
    this.cancelled,
    this.thisWeek,
    this.thisMonth,
    this.thisDay,
    this.createdFrom,
    this.createdTo,
    this.appointmentFrom,
    this.appointmentTo,
  });

  final bool? confirmed;
  final bool? completed;
  final bool? cancelled;
  final bool? thisWeek;
  final bool? thisMonth;
  final bool? thisDay;
  final DateTime? createdFrom;
  final DateTime? createdTo;
  final DateTime? appointmentFrom;
  final DateTime? appointmentTo;

  Map<String, String> toQueryMap() {
    final m = <String, String>{};
    if (confirmed == true) m['Confirmed'] = 'true';
    if (completed == true) m['Completed'] = 'true';
    if (cancelled == true) m['Cancelled'] = 'true';
    if (thisWeek == true) m['ThisWeek'] = 'true';
    if (thisMonth == true) m['ThisMounth'] = 'true';
    if (thisDay == true) m['ThisDay'] = 'true';
    if (createdFrom != null) m['from'] = createdFrom!.toUtc().toIso8601String();
    if (createdTo != null) m['to'] = createdTo!.toUtc().toIso8601String();
    if (appointmentFrom != null) {
      m['AppointmentFrom'] = appointmentFrom!.toIso8601String();
    }
    if (appointmentTo != null) {
      m['AppointmentTo'] = appointmentTo!.toIso8601String();
    }
    return m;
  }
}
