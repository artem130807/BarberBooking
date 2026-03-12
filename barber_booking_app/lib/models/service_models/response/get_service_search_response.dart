import 'package:barber_booking_app/models/salon_models/response/salon_navigation_response.dart';
import 'package:barber_booking_app/models/vo_models/dto_price.dart';

class GetServiceSearchResponse{
  String? id;
  String? name;
  int? durationMinutes;
  DtoPrice? price;
  String? photoUrl;
  SalonNavigationResponse? dtoSalonNavigation;

  GetServiceSearchResponse({this.id, this.name, this.durationMinutes, this.price, this.photoUrl, this.dtoSalonNavigation});
  factory GetServiceSearchResponse.fromJson(Map<String, dynamic> json){
    return GetServiceSearchResponse(
      id: json['id'],
      name: json['name'],
      durationMinutes: json['durationMinutes'],
      price: json['price'] != null ? DtoPrice.fromJson(json['price']): null,
      photoUrl: json['photoUrl'],
      dtoSalonNavigation: json['dtoSalonNavigation'] != null ? SalonNavigationResponse.fromJson(json['dtoSalonNavigation']) : null,
    );
  }
}