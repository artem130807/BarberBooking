import 'package:barber_booking_app/models/salon_models/response/salon_navigation_response.dart';

class GetMasterprofileSubscriptionInfoResponse {
  String? Id;
  String? MasterName;
  String? AvatarUrl;
  double? Rating;
  SalonNavigationResponse? SalonNavigation;
  GetMasterprofileSubscriptionInfoResponse({this.Id, this.MasterName, this.AvatarUrl, this.Rating, this.SalonNavigation});

  factory GetMasterprofileSubscriptionInfoResponse.fromJson(Map<String, dynamic> json){
    final ratingRaw = json['rating'] ?? json['Rating'];
    final salonNavRaw = json['salonNavigation'] ?? json['SalonNavigation'];
    return GetMasterprofileSubscriptionInfoResponse(
      Id: json['id']?.toString() ?? json['Id']?.toString(),
      MasterName: json['masterName'] as String? ?? json['MasterName'] as String?,
      AvatarUrl: json['avatarUrl'] as String? ?? json['AvatarUrl'] as String?,
      Rating: ratingRaw is num ? ratingRaw.toDouble() : null,
      SalonNavigation: salonNavRaw != null
          ? SalonNavigationResponse.fromJson(
              Map<String, dynamic>.from(salonNavRaw as Map),
            )
          : null,
    );
  }
}