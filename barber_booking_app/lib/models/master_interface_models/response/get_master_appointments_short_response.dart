import 'package:barber_booking_app/models/vo_models/dto_price.dart';

class GetMasterAppointmentsShortResponse {
  String? Id;
  String? UserName;
  String? ServiceName;
  String? StartTime;
  String? EndTime;
  DtoPrice? Price;
  String? AppointmentDate;

  GetMasterAppointmentsShortResponse({
    this.Id,
    this.UserName,
    this.ServiceName,
    this.StartTime,
    this.EndTime,
    this.Price,
    this.AppointmentDate,
  });

  factory GetMasterAppointmentsShortResponse.fromJson(Map<String, dynamic> json) {
    return GetMasterAppointmentsShortResponse(
      Id: json['id'],
      UserName: json['userName'],
      ServiceName: json['serviceName'],
      StartTime: json['startTime'],
      EndTime: json['endTime'],
      Price: json['price'] != null ? DtoPrice.fromJson(json['price']) : null,
      AppointmentDate: json['appointmentDate'],
    );
  }
}
