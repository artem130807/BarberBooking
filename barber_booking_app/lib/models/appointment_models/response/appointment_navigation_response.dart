import 'package:barber_booking_app/models/vo_models/dto_price.dart';

class AppointmentNavigationResponse {
  String? Id;
  String? ServiceName;
  DtoPrice? Price;
  String? PhotoUrl;
  AppointmentNavigationResponse({this.Id, this.ServiceName, this.Price, this.PhotoUrl});

  factory AppointmentNavigationResponse.fromJson(Map<String, dynamic> json){
    return AppointmentNavigationResponse(
      Id: json['id'],
      ServiceName: json['serviceName'],
      Price: json['price'] != null ? DtoPrice.fromJson(json['price']): null,
      PhotoUrl: json['photoUrl']
    );
  }
}
