import 'package:barber_booking_app/models/appointment_models/response/appointment_navigation_response.dart';
import 'package:barber_booking_app/models/master_models/response/master_navigation_response.dart';
import 'package:barber_booking_app/models/salon_models/response/salon_navigation_response.dart';
import 'package:barber_booking_app/screens/user_interfaces/appointment_screens/appointments_screen.dart';

class GetReviewsUserResponse {
  String? Id;
  int? SalonRating;
  int? MasterRating;
  String? ServiceName;
  AppointmentNavigationResponse? dtoAppointmentNavigation;
  SalonNavigationResponse? dtoSalonNavigation;
  MasterNavigationResponse? masterProfileNavigation;
  String? Comment;
  String? CreatedAt;
  
  GetReviewsUserResponse({this.Id, this.SalonRating, this.MasterRating, this.ServiceName, this.dtoAppointmentNavigation,
  this.dtoSalonNavigation, this.masterProfileNavigation, 
  this.Comment, this.CreatedAt});

  factory GetReviewsUserResponse.fromJson(Map<String, dynamic> json){
      return GetReviewsUserResponse(
        Id: json['id'],
        SalonRating: json['salonRating'],
        MasterRating: json['masterRating'],
        ServiceName: json['serviceName'],
        dtoAppointmentNavigation: json['dtoAppointmentNavigation'] != null ? AppointmentNavigationResponse.fromJson(json['dtoAppointmentNavigation']): null,
        dtoSalonNavigation: json['dtoSalonNavigation'] != null ? SalonNavigationResponse.fromJson(json['dtoSalonNavigation']): null,
       masterProfileNavigation: json['masterProfileNavigation'] != null ? MasterNavigationResponse.fromJson(json['masterProfileNavigation']): null,
        Comment: json['comment'],
        CreatedAt: json['createdAt']
      );
  }
}