import 'package:barber_booking_app/models/master_models/response/master_navigation_response.dart';
import 'package:barber_booking_app/models/service_models/response/service_navigation_response.dart';
import 'package:barber_booking_app/utils/appointment_status_normalize.dart';

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
    dynamic v(String a, String b) => json[a] ?? json[b];
    final mNav = v('dtoMasterProfileNavigation', 'DtoMasterProfileNavigation');
    final sNav = v('dtoServicesNavigation', 'DtoServicesNavigation');
    final ad = v('appointmentDate', 'AppointmentDate');
    return GetAppointmentClientResponse(
      Id: v('id', 'Id')?.toString(),
      ClientNotes: v('clientNotes', 'ClientNotes')?.toString(),
      SalonId: v('salonId', 'SalonId')?.toString(),
      SalonName: v('salonName', 'SalonName')?.toString(),
      dtoMasterProfileNavigation: mNav != null
          ? MasterNavigationResponse.fromJson(
              Map<String, dynamic>.from(mNav as Map))
          : null,
      dtoServicesNavigation: sNav != null
          ? ServiceNavigationResponse.fromJson(
              Map<String, dynamic>.from(sNav as Map))
          : null,
      Status: normalizeAppointmentStatus(v('status', 'Status')?.toString()),
      StartTime: v('startTime', 'StartTime')?.toString(),
      EndTime: v('endTime', 'EndTime')?.toString(),
      AppointmentDate:
          ad != null ? DateTime.tryParse(ad.toString()) : null,
    );
  }
}
