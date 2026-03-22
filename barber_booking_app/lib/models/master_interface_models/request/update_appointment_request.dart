import 'package:barber_booking_app/models/base/json_serializable.dart';

class UpdateAppointmentRequest extends JsonSerializable {
  String? ServiceId;
  String? StartTime;
  String? ClientNotes;
  String? Status;

  UpdateAppointmentRequest({
    this.ServiceId,
    this.StartTime,
    this.ClientNotes,
    this.Status,
  });

  @override
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (ServiceId != null) map['serviceId'] = ServiceId;
    if (StartTime != null) map['startTime'] = StartTime;
    if (ClientNotes != null) map['clientNotes'] = ClientNotes;
    if (Status != null) map['status'] = Status;
    return map;
  }
}
