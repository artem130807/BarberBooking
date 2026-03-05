import 'package:barber_booking_app/models/vo_models/dto_address.dart';

class SalonNavigationResponse {
  String? Id;
  String? SalonName;
  DtoAddress? Address;
  String? MainPhotoUrl;
  double? Rating;
  int? RatingCount;

  SalonNavigationResponse({this.Id, this.SalonName, this.Address, this.MainPhotoUrl, this.Rating, this.RatingCount});

  factory SalonNavigationResponse.fromJson(Map<String, dynamic> json){
    return SalonNavigationResponse(
      Id: json['id'],
      SalonName: json['salonName'],
      Address: json['address'] != null
      ? DtoAddress.fromJson(json['address'])
      : null,
      MainPhotoUrl: json['mainPhotoUrl'],
      Rating: json['rating'],
      RatingCount: json['ratingCount']
    );
  }
}