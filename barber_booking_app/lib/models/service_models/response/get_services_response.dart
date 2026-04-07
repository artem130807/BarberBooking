import 'package:barber_booking_app/models/vo_models/dto_price.dart';

class GetServicesResponse {
  String? Id;
  String? Name;
  String? PhotoUrl;
  int? DurationMinutes;
  DtoPrice? Price;

  GetServicesResponse({this.Id, this.Name, this.PhotoUrl,this.DurationMinutes, this.Price});

  factory GetServicesResponse.fromJson(Map<String, dynamic> json) {
    dynamic v(String a, String b) => json[a] ?? json[b];
    final dm = v('durationMinutes', 'DurationMinutes');
    int? d;
    if (dm is int) {
      d = dm;
    } else if (dm != null) {
      d = int.tryParse(dm.toString());
    }
    final priceRaw = v('price', 'Price');
    return GetServicesResponse(
      Id: v('id', 'Id')?.toString(),
      Name: v('name', 'Name')?.toString(),
      PhotoUrl: v('photoUrl', 'PhotoUrl')?.toString(),
      DurationMinutes: d,
      Price: priceRaw is Map
          ? DtoPrice.fromJson(Map<String, dynamic>.from(priceRaw))
          : null,
    );
  }
}