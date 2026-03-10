import 'package:barber_booking_app/models/vo_models/dto_price.dart';

class GetServicesResponse {
  String? Id;
  String? Name;
  String? PhotoUrl;
  int? DurationMinutes;
  DtoPrice? Price;

  GetServicesResponse({this.Id, this.Name, this.PhotoUrl,this.DurationMinutes, this.Price});

   factory GetServicesResponse.fromJson(Map<String, dynamic> json){
      return  GetServicesResponse(
          Id: json['id'],
          Name: json['name'],
          PhotoUrl: json['photoUrl'],
          DurationMinutes: json['durationMinutes'],
          Price: json['price'] != null ? DtoPrice.fromJson(json['price']): null
      );
    }
}