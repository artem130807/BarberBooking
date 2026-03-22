import 'package:barber_booking_app/models/appointment_models/response/appointment_navigation_response.dart';
import 'package:barber_booking_app/models/master_models/response/master_navigation_response.dart';
import 'package:barber_booking_app/models/salon_models/response/salon_navigation_response.dart';

class ReviewAdminListItem {
  String? Id;
  String? AppointmentId;
  String? ClientId;
  String? SalonId;
  String? ClientName;
  int? SalonRating;
  int? MasterRating;
  String? Comment;
  DateTime? CreatedAt;
  SalonNavigationResponse? dtoSalonNavigation;
  MasterNavigationResponse? masterProfileNavigation;
  AppointmentNavigationResponse? dtoAppointmentNavigation;

  ReviewAdminListItem({
    this.Id,
    this.AppointmentId,
    this.ClientId,
    this.SalonId,
    this.ClientName,
    this.SalonRating,
    this.MasterRating,
    this.Comment,
    this.CreatedAt,
    this.dtoSalonNavigation,
    this.masterProfileNavigation,
    this.dtoAppointmentNavigation,
  });

  factory ReviewAdminListItem.fromJson(Map<String, dynamic> json) {
    return ReviewAdminListItem(
      Id: json['id']?.toString(),
      AppointmentId: json['appointmentId']?.toString(),
      ClientId: json['clientId']?.toString(),
      SalonId: json['salonId']?.toString(),
      ClientName: json['clientName'],
      SalonRating: _toInt(json['salonRating']),
      MasterRating: _toInt(json['masterRating']),
      Comment: json['comment'],
      CreatedAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
      dtoSalonNavigation: json['dtoSalonNavigation'] != null
          ? SalonNavigationResponse.fromJson(
              Map<String, dynamic>.from(json['dtoSalonNavigation'] as Map),
            )
          : null,
      masterProfileNavigation: json['masterProfileNavigation'] != null
          ? MasterNavigationResponse.fromJson(
              Map<String, dynamic>.from(json['masterProfileNavigation'] as Map),
            )
          : null,
      dtoAppointmentNavigation: json['dtoAppointmentNavigation'] != null
          ? AppointmentNavigationResponse.fromJson(
              Map<String, dynamic>.from(json['dtoAppointmentNavigation'] as Map),
            )
          : null,
    );
  }

  static int? _toInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse(v.toString());
  }
}
