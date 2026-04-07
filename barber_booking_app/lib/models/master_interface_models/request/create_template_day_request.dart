class CreateTemplateDayRequest {
  CreateTemplateDayRequest({
    required this.weeklyTemplateId,
    required this.dayOfWeek,
    required this.workStartTime,
    required this.workEndTime,
  });

  final String weeklyTemplateId;
  final int dayOfWeek;
  final String workStartTime;
  final String workEndTime;

  Map<String, dynamic> toJson() => {
        'weeklyTemplateId': weeklyTemplateId,
        'dayOfWeek': dayOfWeek,
        'workStartTime': workStartTime,
        'workEndTime': workEndTime,
      };
}
