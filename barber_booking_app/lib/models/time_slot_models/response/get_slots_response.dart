class GetSlotsResponse {
    String? Id;
    String? MasterId;
    String? ScheduleDate;
    String? StartTime;
    String? EndTime;
    String? Status;
    GetSlotsResponse({this.Id, this.MasterId, this.ScheduleDate, this.StartTime, this.EndTime, this.Status});

    factory GetSlotsResponse.fromJson(Map<String, dynamic> json){
      return GetSlotsResponse(
        Id: json['id'],
        MasterId: json['masterId'],
        ScheduleDate: json['scheduleDate'],
        StartTime: json['startTime'],
        EndTime: json['endTime'],
        Status: json['status']
      );
    }
}