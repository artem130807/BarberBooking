import 'package:barber_booking_app/models/master_interface_models/response/users_navigation_response.dart';
import 'package:barber_booking_app/models/service_models/response/service_navigation_response.dart';

class GetMasterAppointmentInfoResponse {
  String? Id;
  String? ClientNotes;
  String? SalonId;
  String? SalonName;
  UsersNavigationResponse? dtoUsersNavigation;
  ServiceNavigationResponse? dtoServicesNavigation;
  String? Status;
  String? StartTime;
  String? EndTime;
  DateTime? AppointmentDate;

  GetMasterAppointmentInfoResponse({
    this.Id,
    this.ClientNotes,
    this.SalonId,
    this.SalonName,
    this.dtoUsersNavigation,
    this.dtoServicesNavigation,
    this.Status,
    this.StartTime,
    this.EndTime,
    this.AppointmentDate,
  });

  factory GetMasterAppointmentInfoResponse.fromJson(Map<String, dynamic> json) {
    return GetMasterAppointmentInfoResponse(
      Id: json['id'],
      ClientNotes: json['clientNotes'],
      SalonId: json['salonId'],
      SalonName: json['salonName'],
      dtoUsersNavigation: json['dtoUsersNavigation'] != null
          ? UsersNavigationResponse.fromJson(json['dtoUsersNavigation'])
          : null,
      dtoServicesNavigation: json['dtoServicesNavigation'] != null
          ? ServiceNavigationResponse.fromJson(json['dtoServicesNavigation'])
          : null,
      Status: json['status'],
      StartTime: json['startTime'],
      EndTime: json['endTime'],
      AppointmentDate: json['appointmentDate'] != null
          ? DateTime.tryParse(json['appointmentDate'].toString())
          : null,
    );
  }
}
