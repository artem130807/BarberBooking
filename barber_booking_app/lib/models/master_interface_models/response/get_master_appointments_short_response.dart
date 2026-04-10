import 'package:barber_booking_app/models/vo_models/dto_price.dart';
import 'package:barber_booking_app/utils/appointment_status_normalize.dart';

class GetMasterAppointmentsShortResponse {
  String? Id;
  String? UserName;
  String? ServiceName;
  String? StartTime;
  String? EndTime;
  DtoPrice? Price;
  String? AppointmentDate;
  String? Status;
  bool? CreatedWithoutApp;

  GetMasterAppointmentsShortResponse({
    this.Id,
    this.UserName,
    this.ServiceName,
    this.StartTime,
    this.EndTime,
    this.Price,
    this.AppointmentDate,
    this.Status,
    this.CreatedWithoutApp,
  });

  factory GetMasterAppointmentsShortResponse.fromJson(Map<String, dynamic> json) {
    dynamic v(String a, String b) => json[a] ?? json[b];
    final price = v('price', 'Price');
    return GetMasterAppointmentsShortResponse(
      Id: v('id', 'Id')?.toString(),
      UserName: v('userName', 'UserName')?.toString(),
      ServiceName: v('serviceName', 'ServiceName')?.toString(),
      StartTime: v('startTime', 'StartTime')?.toString(),
      EndTime: v('endTime', 'EndTime')?.toString(),
      Price: price != null
          ? DtoPrice.fromJson(Map<String, dynamic>.from(price as Map))
          : null,
      AppointmentDate: v('appointmentDate', 'AppointmentDate')?.toString(),
      Status: normalizeAppointmentStatus(v('status', 'Status')?.toString()),
      CreatedWithoutApp: _parseBool(v('createdWithoutApp', 'CreatedWithoutApp')),
    );
  }

  static bool? _parseBool(dynamic v) {
    if (v == null) return null;
    if (v is bool) return v;
    return v == true || v == 'true';
  }
}
