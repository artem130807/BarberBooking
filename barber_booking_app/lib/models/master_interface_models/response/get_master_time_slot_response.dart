class GetMasterTimeSlotResponse {
  String? Id;
  String? MasterId;
  String? ScheduleDate;
  String? StartTime;
  String? EndTime;
  String? Status;
  int? TimeSlotCount;

  GetMasterTimeSlotResponse({
    this.Id,
    this.MasterId,
    this.ScheduleDate,
    this.StartTime,
    this.EndTime,
    this.Status,
    this.TimeSlotCount,
  });

  factory GetMasterTimeSlotResponse.fromJson(Map<String, dynamic> json) {
    dynamic v(String a, String b) => json[a] ?? json[b];
    final statusRaw = v('status', 'Status');
    final countRaw =
        v('timeSlotCount', 'TimeSlotCount') ?? v('timeClotCount', 'TimeClotCount');
    return GetMasterTimeSlotResponse(
      Id: v('id', 'Id')?.toString(),
      MasterId: v('masterId', 'MasterId')?.toString(),
      ScheduleDate: v('scheduleDate', 'ScheduleDate')?.toString(),
      StartTime: v('startTime', 'StartTime')?.toString(),
      EndTime: v('endTime', 'EndTime')?.toString(),
      Status: _statusToString(statusRaw),
      TimeSlotCount: _parseInt(countRaw),
    );
  }

  static int? _parseInt(dynamic raw) {
    if (raw == null) return null;
    if (raw is int) return raw;
    if (raw is num) return raw.toInt();
    return int.tryParse(raw.toString());
  }

  static String? _statusToString(dynamic raw) {
    if (raw == null) return null;
    if (raw is int) {
      switch (raw) {
        case 0:
          return 'Available';
        case 1:
          return 'Booked';
        case 2:
          return 'Cancelled';
        default:
          return raw.toString();
      }
    }
    final s = raw.toString();
    if (s == '0' || s == '1' || s == '2') {
      return _statusToString(int.tryParse(s));
    }
    return s;
  }

  bool get isCancelled => Status == 'Cancelled';
}
