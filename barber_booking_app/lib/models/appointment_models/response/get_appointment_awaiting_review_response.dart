import 'package:barber_booking_app/models/master_models/response/master_navigation_response.dart';
import 'package:barber_booking_app/models/salon_models/response/salon_navigation_response.dart';
import 'package:barber_booking_app/models/service_models/response/service_navigation_response.dart';

class GetAppointmentAwaitingReviewResponse{
  String? id;
  ServiceNavigationResponse? serviceNavigationResponse;
  MasterNavigationResponse? masterNavigationResponse;
  SalonNavigationResponse? salonNavigationResponse;
  DateTime? AppointmentDate;

  GetAppointmentAwaitingReviewResponse({this.id ,this.serviceNavigationResponse, this.masterNavigationResponse, this.salonNavigationResponse, this.AppointmentDate});

    factory GetAppointmentAwaitingReviewResponse.fromJson(Map<String, dynamic> json){
    return GetAppointmentAwaitingReviewResponse(
      id: json['id'],
      salonNavigationResponse: json['dtoSalonNavigation'] != null
          ? SalonNavigationResponse.fromJson(json['dtoSalonNavigation'])
          : null,
      masterNavigationResponse: json['dtoMasterProfileNavigation'] != null
          ? MasterNavigationResponse.fromJson(json['dtoMasterProfileNavigation'])
          : null,
       serviceNavigationResponse: json['dtoServicesNavigation'] != null
          ? ServiceNavigationResponse.fromJson(json['dtoServicesNavigation'])
          : null,
      AppointmentDate: _parseDateTime(json['appointmentDate']),
    );
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (_) {
        return null;
      }
    }
    return null;
  }
}