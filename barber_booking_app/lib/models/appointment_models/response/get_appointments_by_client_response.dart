import 'package:barber_booking_app/models/master_models/response/master_navigation_response.dart';
import 'package:barber_booking_app/models/salon_models/response/salon_navigation_response.dart';
import 'package:barber_booking_app/models/vo_models/dto_price.dart';

class GetAppointmentsByClientResponse{
  String? Id; 
  SalonNavigationResponse? SalonNavigation;
  MasterNavigationResponse? MasterProfileNavigation; 
  String? ServiceName;
  String? StartTime;
  String? EndTime;
  DtoPrice? Price;
  String? AppointmentDate;
  String? Status;
  GetAppointmentsByClientResponse({this.Id, this.SalonNavigation, this.MasterProfileNavigation, this.ServiceName, this.StartTime, this.EndTime, this.Price, this.AppointmentDate, this.Status});

  factory GetAppointmentsByClientResponse.fromJson(Map<String, dynamic> json) {
    dynamic v(String a, String b) => json[a] ?? json[b];
    final salon = v('salonNavigation', 'SalonNavigation');
    final master = v('masterProfileNavigation', 'MasterProfileNavigation');
    final price = v('price', 'Price');
    return GetAppointmentsByClientResponse(
      Id: v('id', 'Id')?.toString(),
      SalonNavigation: salon != null
          ? SalonNavigationResponse.fromJson(
              Map<String, dynamic>.from(salon as Map))
          : null,
      MasterProfileNavigation: master != null
          ? MasterNavigationResponse.fromJson(
              Map<String, dynamic>.from(master as Map))
          : null,
      ServiceName: v('serviceName', 'ServiceName')?.toString(),
      StartTime: v('startTime', 'StartTime')?.toString(),
      EndTime: v('endTime', 'EndTime')?.toString(),
      Price: price != null
          ? DtoPrice.fromJson(Map<String, dynamic>.from(price as Map))
          : null,
      AppointmentDate: v('appointmentDate', 'AppointmentDate')?.toString(),
      Status: v('status', 'Status')?.toString(),
    );
  }
}