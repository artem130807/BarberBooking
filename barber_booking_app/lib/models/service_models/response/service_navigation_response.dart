import 'package:barber_booking_app/models/vo_models/dto_price.dart';

class ServiceNavigationResponse {
  String? Id;
  String? Name;
  DtoPrice? Price;
  ServiceNavigationResponse({this.Id, this.Name, this.Price});

   factory ServiceNavigationResponse.fromJson(Map<String, dynamic> json){
    return ServiceNavigationResponse(
      Id: json['id'],
      Name: json['name'],
      Price: json['price'] != null ? DtoPrice.fromJson(json['price']) : null,
    );
  }
 
}