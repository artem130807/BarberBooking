class GetMasterTimeSlotResponse {
  String? Id;
  String? MasterId;
  String? ScheduleDate;
  String? StartTime;
  String? EndTime;
  String? Status;

  GetMasterTimeSlotResponse({
    this.Id,
    this.MasterId,
    this.ScheduleDate,
    this.StartTime,
    this.EndTime,
    this.Status,
  });

  factory GetMasterTimeSlotResponse.fromJson(Map<String, dynamic> json) {
    return GetMasterTimeSlotResponse(
      Id: json['id'],
      MasterId: json['masterId'],
      ScheduleDate: json['scheduleDate'],
      StartTime: json['startTime'],
      EndTime: json['endTime'],
      Status: json['status'],
    );
  }
}
