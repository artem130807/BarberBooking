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
  bool? isSubscripe;

  GetMasterResponse({
    this.Id,
    this.UserName,
    this.SalonNavigation,
    this.Bio,
    this.Specialization,
    this.AvatarUrl,
    this.Rating,
    this.RatingCount,
    this.isSubscripe,
  });

  factory GetMasterResponse.fromJson(Map<String, dynamic> json) {
    dynamic v(String a, String b) => json[a] ?? json[b];
    final nav = v('salonNavigation', 'SalonNavigation');
    return GetMasterResponse(
      Id: v('id', 'Id')?.toString(),
      UserName: v('userName', 'UserName')?.toString(),
      SalonNavigation: nav != null
          ? SalonNavigationResponse.fromJson(
              Map<String, dynamic>.from(nav as Map),
            )
          : null,
      Bio: v('bio', 'Bio')?.toString(),
      Specialization: v('specialization', 'Specialization')?.toString(),
      AvatarUrl: v('avatarUrl', 'AvatarUrl')?.toString(),
      Rating: (v('rating', 'Rating') as num?)?.toDouble(),
      RatingCount: _parseInt(v('ratingCount', 'RatingCount')),
      isSubscripe: _parseBool(v('isSubscripe', 'IsSubscripe')),
    );
  }

  static int? _parseInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse(v.toString());
  }

  static bool? _parseBool(dynamic v) {
    if (v == null) return null;
    if (v is bool) return v;
    return v == true || v == 'true';
  }
}