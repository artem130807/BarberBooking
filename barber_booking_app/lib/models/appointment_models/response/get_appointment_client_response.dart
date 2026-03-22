import 'package:barber_booking_app/models/master_models/response/master_navigation_response.dart';
import 'package:barber_booking_app/models/service_models/response/service_navigation_response.dart';

class GetAppointmentClientResponse {
  String? Id;
  String? ClientNotes;
  String? SalonId;
  String? SalonName;
  MasterNavigationResponse? dtoMasterProfileNavigation;
  ServiceNavigationResponse? dtoServicesNavigation;
  String? Status;
  String? StartTime;
  String? EndTime;
  DateTime? AppointmentDate;

  GetAppointmentClientResponse({
    this.Id,
    this.ClientNotes,
    this.SalonId,
    this.SalonName,
    this.dtoMasterProfileNavigation,
    this.dtoServicesNavigation,
    this.Status,
    this.StartTime,
    this.EndTime,
    this.AppointmentDate,
  });

  factory GetAppointmentClientResponse.fromJson(Map<String, dynamic> json) {
    return GetAppointmentClientResponse(
      Id: json['id'],
      ClientNotes: json['clientNotes'],
      SalonId: json['salonId'],
      SalonName: json['salonName'],
      dtoMasterProfileNavigation: json['dtoMasterProfileNavigation'] != null
          ? MasterNavigationResponse.fromJson(json['dtoMasterProfileNavigation'])
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
