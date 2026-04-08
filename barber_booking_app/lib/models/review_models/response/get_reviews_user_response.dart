import 'package:barber_booking_app/models/appointment_models/response/appointment_navigation_response.dart';
import 'package:barber_booking_app/models/master_models/response/master_navigation_response.dart';
import 'package:barber_booking_app/models/salon_models/response/salon_navigation_response.dart';

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

  factory GetReviewsUserResponse.fromJson(Map<String, dynamic> json) {
    dynamic v(String a, String b) => json[a] ?? json[b];
    final appt = v('dtoAppointmentNavigation', 'DtoAppointmentNavigation');
    final salon = v('dtoSalonNavigation', 'DtoSalonNavigation');
    final master = v('masterProfileNavigation', 'MasterProfileNavigation');
    return GetReviewsUserResponse(
      Id: v('id', 'Id')?.toString(),
      SalonRating: _parseInt(v('salonRating', 'SalonRating')),
      MasterRating: _parseInt(v('masterRating', 'MasterRating')),
      ServiceName: v('serviceName', 'ServiceName')?.toString(),
      dtoAppointmentNavigation: appt != null
          ? AppointmentNavigationResponse.fromJson(
              Map<String, dynamic>.from(appt as Map))
          : null,
      dtoSalonNavigation: salon != null
          ? SalonNavigationResponse.fromJson(
              Map<String, dynamic>.from(salon as Map))
          : null,
      masterProfileNavigation: master != null
          ? MasterNavigationResponse.fromJson(
              Map<String, dynamic>.from(master as Map))
          : null,
      Comment: v('comment', 'Comment')?.toString(),
      CreatedAt: v('createdAt', 'CreatedAt')?.toString(),
    );
  }

  static int? _parseInt(dynamic x) {
    if (x == null) return null;
    if (x is int) return x;
    if (x is num) return x.toInt();
    return int.tryParse(x.toString());
  }
}