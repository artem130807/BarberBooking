class WeeklyTemplateShortInfo {
  WeeklyTemplateShortInfo({
    this.id,
    this.name,
    this.isActive,
    this.templateDayCount,
  });

  String? id;
  String? name;
  bool? isActive;
  int? templateDayCount;

  factory WeeklyTemplateShortInfo.fromJson(Map<String, dynamic> json) {
    dynamic v(String a, String b) => json[a] ?? json[b];
    final countRaw = v('templateDayCount', 'TemplateDayCount');
    int? c;
    if (countRaw is int) {
      c = countRaw;
    } else if (countRaw != null) {
      c = int.tryParse(countRaw.toString());
    }
    return WeeklyTemplateShortInfo(
      id: v('id', 'Id')?.toString(),
      name: v('name', 'Name')?.toString(),
      isActive: v('isActive', 'IsActive') as bool?,
      templateDayCount: c,
    );
  }
}
