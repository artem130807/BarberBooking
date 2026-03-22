import 'package:barber_booking_app/models/base/json_serializable.dart';

class CreateTimeSlotRequest extends JsonSerializable {
  String? MasterId;
  String? ScheduleDate;
  String? StartTime;
  String? EndTime;

  CreateTimeSlotRequest({
    this.MasterId,
    this.ScheduleDate,
    this.StartTime,
    this.EndTime,
  });

  @override
  Map<String, dynamic> toJson() {
    return {
      'masterId': MasterId,
      'scheduleDate': ScheduleDate,
      'startTime': StartTime,
      'endTime': EndTime,
    };
  }
}
