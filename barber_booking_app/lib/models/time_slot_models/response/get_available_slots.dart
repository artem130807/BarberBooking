class GetAvailableSlots {
  String? id;
  String? startTime;
  String? endTime;

  GetAvailableSlots({this.id, this.startTime, this.endTime});

  factory GetAvailableSlots.fromJson(Map<String, dynamic> json) {
    return GetAvailableSlots(
      id: json['id']?.toString() ?? json['Id']?.toString(),
      startTime: _stringifyTime(json['startTime'] ?? json['StartTime']),
      endTime: _stringifyTime(json['endTime'] ?? json['EndTime']),
    );
  }

  static String? _stringifyTime(dynamic v) {
    if (v == null) return null;
    if (v is String) return v;
    return v.toString();
  }
}