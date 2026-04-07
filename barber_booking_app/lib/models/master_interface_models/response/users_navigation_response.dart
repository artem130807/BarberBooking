import 'package:barber_booking_app/models/vo_models/dto_phone.dart';

class UsersNavigationResponse {
  String? Id;
  String? Name;
  DtoPhone? dtoPhone;

  UsersNavigationResponse({this.Id, this.Name, this.dtoPhone});

  factory UsersNavigationResponse.fromJson(Map<String, dynamic> json) {
    dynamic v(String a, String b) => json[a] ?? json[b];
    final phone = v('dtoPhone', 'DtoPhone');
    return UsersNavigationResponse(
      Id: v('id', 'Id')?.toString(),
      Name: v('name', 'Name')?.toString(),
      dtoPhone: phone != null
          ? DtoPhone.fromJson(Map<String, dynamic>.from(phone as Map))
          : null,
    );
  }
}
