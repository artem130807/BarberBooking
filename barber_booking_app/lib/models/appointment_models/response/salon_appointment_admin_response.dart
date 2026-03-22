import 'package:barber_booking_app/models/appointment_models/response/users_navigation_response.dart';
import 'package:barber_booking_app/models/master_models/response/master_navigation_response.dart';
import 'package:barber_booking_app/models/service_models/response/service_navigation_response.dart';

class SalonAppointmentAdminResponse {
  String? Id;
  String? ClientId;
  String? MasterId;
  String? ServiceId;
  String? SalonId;
  String? SalonName;
  String? ClientNotes;
  UsersNavigationResponse? dtoUsersNavigation;
  MasterNavigationResponse? dtoMasterProfileNavigation;
  ServiceNavigationResponse? dtoServicesNavigation;
  String? Status;
  String? StartTime;
  String? EndTime;
  DateTime? AppointmentDate;
  DateTime? CreatedAt;
  DateTime? UpdatedAt;

  SalonAppointmentAdminResponse({
    this.Id,
    this.ClientId,
    this.MasterId,
    this.ServiceId,
    this.SalonId,
    this.SalonName,
    this.ClientNotes,
    this.dtoUsersNavigation,
    this.dtoMasterProfileNavigation,
    this.dtoServicesNavigation,
    this.Status,
    this.StartTime,
    this.EndTime,
    this.AppointmentDate,
    this.CreatedAt,
    this.UpdatedAt,
  });

  factory SalonAppointmentAdminResponse.fromJson(Map<String, dynamic> json) {
    return SalonAppointmentAdminResponse(
      Id: json['id']?.toString(),
      ClientId: json['clientId']?.toString(),
      MasterId: json['masterId']?.toString(),
      ServiceId: json['serviceId']?.toString(),
      SalonId: json['salonId']?.toString(),
      SalonName: json['salonName'],
      ClientNotes: json['clientNotes'],
      dtoUsersNavigation: json['dtoUsersNavigation'] != null
          ? UsersNavigationResponse.fromJson(
              Map<String, dynamic>.from(json['dtoUsersNavigation'] as Map),
            )
          : null,
      dtoMasterProfileNavigation: json['dtoMasterProfileNavigation'] != null
          ? MasterNavigationResponse.fromJson(
              Map<String, dynamic>.from(json['dtoMasterProfileNavigation'] as Map),
            )
          : null,
      dtoServicesNavigation: json['dtoServicesNavigation'] != null
          ? ServiceNavigationResponse.fromJson(
              Map<String, dynamic>.from(json['dtoServicesNavigation'] as Map),
            )
          : null,
      Status: json['status']?.toString(),
      StartTime: json['startTime']?.toString(),
      EndTime: json['endTime']?.toString(),
      AppointmentDate: _parseDt(json['appointmentDate']),
      CreatedAt: _parseDt(json['createdAt']),
      UpdatedAt: _parseDt(json['updatedAt']),
    );
  }

  static DateTime? _parseDt(dynamic v) {
    if (v == null) return null;
    if (v is String) return DateTime.tryParse(v);
    return null;
  }
}
