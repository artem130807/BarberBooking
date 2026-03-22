import 'package:barber_booking_app/models/base/json_serializable.dart';

class CreateAppointmentRequest extends JsonSerializable {
  
  String? SalonId;
  String? MasterId;
  String? ServiceId;
  String? TimeSlotId;
  String? ClientNotes;
  String? StartTime;
  DateTime? AppointmentDate;

  CreateAppointmentRequest({this.SalonId, this.MasterId, this.ServiceId, this.TimeSlotId, this.ClientNotes, this.StartTime, this.AppointmentDate});
  @override
  Map<String, dynamic> toJson() {
    return{
      'salonId':SalonId,
      'masterId':MasterId,
      'serviceId':ServiceId,
      'timeSlotId':TimeSlotId,
      'clientNotes':ClientNotes,
      'startTime':StartTime,
      'appointmentDate':AppointmentDate?.toIso8601String()
    };
  }

  
}