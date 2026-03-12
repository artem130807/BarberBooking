import 'package:barber_booking_app/models/salon_models/response/salon_navigation_response.dart';
import 'package:flutter/foundation.dart';

class GetMasterprofileSubscriptionInfoResponse {
  String? Id;
  String? MasterName;
  String? AvatarUrl;
  double? Rating;
  SalonNavigationResponse? SalonNavigation;
  GetMasterprofileSubscriptionInfoResponse({this.Id, this.MasterName, this.AvatarUrl, this.Rating, this.SalonNavigation});

  factory GetMasterprofileSubscriptionInfoResponse.fromJson(Map<String, dynamic> json){
    return GetMasterprofileSubscriptionInfoResponse(
      Id: json['id'],
      MasterName: json['masterName'],
      AvatarUrl: json['avatarUrl'],
      Rating: json['rating'],
      SalonNavigation: json['salonNavigation'] != null ? SalonNavigationResponse.fromJson(json['salonNavigation']) : null,
    );
  }
}