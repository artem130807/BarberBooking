import 'package:barber_booking_app/models/master_interface_models/response/users_navigation_response.dart';
import 'package:barber_booking_app/utils/appointment_status_normalize.dart';
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
  bool? CreatedWithoutApp;

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
    this.CreatedWithoutApp,
  });

  factory GetMasterAppointmentInfoResponse.fromJson(Map<String, dynamic> json) {
    dynamic v(String a, String b) => json[a] ?? json[b];
    final usersNav = v('dtoUsersNavigation', 'DtoUsersNavigation');
    final servicesNav = v('dtoServicesNavigation', 'DtoServicesNavigation');
    final ad = v('appointmentDate', 'AppointmentDate');
    return GetMasterAppointmentInfoResponse(
      Id: v('id', 'Id')?.toString(),
      ClientNotes: v('clientNotes', 'ClientNotes')?.toString(),
      SalonId: v('salonId', 'SalonId')?.toString(),
      SalonName: v('salonName', 'SalonName')?.toString(),
      dtoUsersNavigation: usersNav != null
          ? UsersNavigationResponse.fromJson(
              Map<String, dynamic>.from(usersNav as Map),
            )
          : null,
      dtoServicesNavigation: servicesNav != null
          ? ServiceNavigationResponse.fromJson(
              Map<String, dynamic>.from(servicesNav as Map),
            )
          : null,
      Status: normalizeAppointmentStatus(v('status', 'Status')?.toString()),
      StartTime: v('startTime', 'StartTime')?.toString(),
      EndTime: v('endTime', 'EndTime')?.toString(),
      AppointmentDate: ad != null ? DateTime.tryParse(ad.toString()) : null,
      CreatedWithoutApp: _parseBool(v('createdWithoutApp', 'CreatedWithoutApp')),
    );
  }

  static bool? _parseBool(dynamic v) {
    if (v == null) return null;
    if (v is bool) return v;
    return v == true || v == 'true';
  }
}
