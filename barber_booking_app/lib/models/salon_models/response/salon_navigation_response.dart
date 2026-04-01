import 'package:barber_booking_app/models/vo_models/dto_address.dart';

class SalonNavigationResponse {
  String? Id;
  String? SalonName;
  DtoAddress? Address;
  String? MainPhotoUrl;
  double? Rating;
  int? RatingCount;

  SalonNavigationResponse({this.Id, this.SalonName, this.Address, this.MainPhotoUrl, this.Rating, this.RatingCount});

  factory SalonNavigationResponse.fromJson(Map<String, dynamic> json) {
    dynamic v(String a, String b) => json[a] ?? json[b];
    final addr = v('address', 'Address');
    return SalonNavigationResponse(
      Id: v('id', 'Id')?.toString(),
      SalonName: v('salonName', 'SalonName')?.toString(),
      Address: addr != null
          ? DtoAddress.fromJson(Map<String, dynamic>.from(addr as Map))
          : null,
      MainPhotoUrl: v('mainPhotoUrl', 'MainPhotoUrl')?.toString(),
      Rating: (v('rating', 'Rating') as num?)?.toDouble(),
      RatingCount: _parseInt(v('ratingCount', 'RatingCount')),
    );
  }

  static int? _parseInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse(v.toString());
  }
}