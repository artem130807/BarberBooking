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

  factory GetAppointmentsByClientResponse.fromJson(Map<String, dynamic> json){
    return GetAppointmentsByClientResponse(
      Id: json['id'],
      SalonNavigation: json['salonNavigation'] != null
          ? SalonNavigationResponse.fromJson(json['salonNavigation'])
          : null,
      MasterProfileNavigation: json['masterProfileNavigation'] != null
          ? MasterNavigationResponse.fromJson(json['masterProfileNavigation'])
          : null,
      ServiceName: json['serviceName'],
      StartTime: json['startTime'],
      EndTime: json['endTime'],
      Price: json['price'] != null ? DtoPrice.fromJson(json['price']) : null,
      AppointmentDate: json['appointmentDate'],
      Status: json['status'],
    );
  }
}