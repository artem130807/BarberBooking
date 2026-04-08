import 'package:barber_booking_app/models/vo_models/dto_price.dart';

class AppointmentNavigationResponse {
  String? Id;
  String? ServiceName;
  DtoPrice? Price;
  String? PhotoUrl;
  AppointmentNavigationResponse({this.Id, this.ServiceName, this.Price, this.PhotoUrl});

  factory AppointmentNavigationResponse.fromJson(Map<String, dynamic> json) {
    dynamic v(String a, String b) => json[a] ?? json[b];
    final price = v('price', 'Price');
    return AppointmentNavigationResponse(
      Id: v('id', 'Id')?.toString(),
      ServiceName: v('serviceName', 'ServiceName')?.toString(),
      Price: price != null
          ? DtoPrice.fromJson(Map<String, dynamic>.from(price as Map))
          : null,
      PhotoUrl: v('photoUrl', 'PhotoUrl')?.toString(),
    );
  }
}
