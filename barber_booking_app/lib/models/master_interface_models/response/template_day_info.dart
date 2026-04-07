class TemplateDayInfo {
  TemplateDayInfo({
    this.id,
    this.weeklyTemplateId,
    this.dayOfWeek,
    this.workStartTime,
    this.workEndTime,
  });

  String? id;
  String? weeklyTemplateId;
  int? dayOfWeek;
  String? workStartTime;
  String? workEndTime;

  factory TemplateDayInfo.fromJson(Map<String, dynamic> json) {
    dynamic v(String a, String b) => json[a] ?? json[b];
    final dow = v('dayOfWeek', 'DayOfWeek');
    int? d;
    if (dow is int) {
      d = dow;
    } else if (dow is num) {
      d = dow.toInt();
    } else if (dow != null) {
      d = int.tryParse(dow.toString());
    }
    return TemplateDayInfo(
      id: v('id', 'Id')?.toString(),
      weeklyTemplateId: v('weeklyTemplateId', 'WeeklyTemplateId')?.toString(),
      dayOfWeek: d,
      workStartTime: v('workStartTime', 'WorkStartTime')?.toString(),
      workEndTime: v('workEndTime', 'WorkEndTime')?.toString(),
    );
  }
}
