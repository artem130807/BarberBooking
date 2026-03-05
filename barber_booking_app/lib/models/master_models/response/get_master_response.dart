import 'package:barber_booking_app/models/salon_models/response/salon_navigation_response.dart';

class GetMasterResponse {
  String? Id;
  String? UserName;
  SalonNavigationResponse? SalonNavigation;
  String? Bio;
  String? Specialization;
  String? AvatarUrl;
  double? Rating;
  int? RatingCount;

  GetMasterResponse({this.Id, this.UserName, this.SalonNavigation, this.Bio, this.Specialization, this.AvatarUrl, this.Rating, this.RatingCount});
  factory GetMasterResponse.fromJson(Map<String, dynamic> json){
    return GetMasterResponse(
      Id: json['id'],
      UserName: json['userName'],
      SalonNavigation: json['salonNavigation'] != null ? SalonNavigationResponse.fromJson(json['salonNavigation']) : null,
      Bio: json['bio'],
      Specialization: json['specialization'],
      AvatarUrl: json['avatarUrl'],
      Rating: json['rating'],
      RatingCount: json['ratingCount']
    );
  }
}