import 'package:barber_booking_app/models/appointment_models/response/users_navigation_response.dart';
import 'package:barber_booking_app/models/master_models/response/master_navigation_response.dart';
import 'package:barber_booking_app/models/service_models/response/service_navigation_response.dart';
import 'package:barber_booking_app/utils/appointment_status_normalize.dart';

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
    dynamic v(String a, String b) => json[a] ?? json[b];
    final usersNav = v('dtoUsersNavigation', 'DtoUsersNavigation');
    final masterNav = v('dtoMasterProfileNavigation', 'DtoMasterProfileNavigation');
    final serviceNav = v('dtoServicesNavigation', 'DtoServicesNavigation');
    return SalonAppointmentAdminResponse(
      Id: v('id', 'Id')?.toString(),
      ClientId: v('clientId', 'ClientId')?.toString(),
      MasterId: v('masterId', 'MasterId')?.toString(),
      ServiceId: v('serviceId', 'ServiceId')?.toString(),
      SalonId: v('salonId', 'SalonId')?.toString(),
      SalonName: v('salonName', 'SalonName')?.toString(),
      ClientNotes: v('clientNotes', 'ClientNotes')?.toString(),
      dtoUsersNavigation: usersNav != null
          ? UsersNavigationResponse.fromJson(
              Map<String, dynamic>.from(usersNav as Map),
            )
          : null,
      dtoMasterProfileNavigation: masterNav != null
          ? MasterNavigationResponse.fromJson(
              Map<String, dynamic>.from(masterNav as Map),
            )
          : null,
      dtoServicesNavigation: serviceNav != null
          ? ServiceNavigationResponse.fromJson(
              Map<String, dynamic>.from(serviceNav as Map),
            )
          : null,
      Status: normalizeAppointmentStatus(v('status', 'Status')?.toString()),
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
