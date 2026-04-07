class SlotAppointmentStatusFilter {
  const SlotAppointmentStatusFilter({
    this.confirmed,
    this.completed,
    this.cancelled,
  });

  final bool? confirmed;
  final bool? completed;
  final bool? cancelled;

  Map<String, String> toQueryMap() {
    final m = <String, String>{};
    if (confirmed == true) m['Confirmed'] = 'true';
    if (completed == true) m['Completed'] = 'true';
    if (cancelled == true) m['Cancelled'] = 'true';
    return m;
  }
}
