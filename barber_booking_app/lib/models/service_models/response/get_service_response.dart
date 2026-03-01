import 'package:barber_booking_app/models/vo_models/dto_price.dart';

class GetServiceResponse {
  String? Id;
  String? Name;
  String? Description;
  int? DurationMinutes;
  DtoPrice? Price;
  String? PhotoUrl;
  bool? IsActive;

  GetServiceResponse({this.Id, this.Name, this.Description, this.DurationMinutes, this.Price, this.PhotoUrl, this.IsActive}); 

   factory GetServiceResponse.fromJson(Map<String, dynamic> json){
      return  GetServiceResponse(
          Id: json['id'],
          Name: json['name'],
          Description: json['description'],
          DurationMinutes: json['durationMinutes'],
          Price: json['price'] != null ? DtoPrice.fromJson(json['value']): null,
          PhotoUrl: json['photoUrl'],
          IsActive: json['isActive'],
      );
    }
}