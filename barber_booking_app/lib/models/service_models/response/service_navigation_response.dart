import 'package:barber_booking_app/models/vo_models/dto_price.dart';

class ServiceNavigationResponse {
  String? Id;
  String? Name;
  DtoPrice? Price;
  ServiceNavigationResponse({this.Id, this.Name, this.Price});

  factory ServiceNavigationResponse.fromJson(Map<String, dynamic> json) {
    dynamic v(String a, String b) => json[a] ?? json[b];
    final price = v('price', 'Price');
    return ServiceNavigationResponse(
      Id: v('id', 'Id')?.toString(),
      Name: v('name', 'Name')?.toString(),
      Price: price != null
          ? DtoPrice.fromJson(Map<String, dynamic>.from(price as Map))
          : null,
    );
  }
 
}