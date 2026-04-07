class UpdateTemplateDayRequest {
  UpdateTemplateDayRequest({
    required this.workStartTime,
    required this.workEndTime,
    this.dayOfWeek,
  });

  final String workStartTime;
  final String workEndTime;
  final int? dayOfWeek;

  Map<String, dynamic> toJson() {
    final m = <String, dynamic>{
      'workStartTime': workStartTime,
      'workEndTime': workEndTime,
    };
    if (dayOfWeek != null) {
      m['dayOfWeek'] = dayOfWeek;
    }
    return m;
  }
}
