import 'package:barber_booking_app/models/vo_models/dto_phone.dart';

class UsersNavigationResponse {
  String? Id;
  String? Name;
  DtoPhone? dtoPhone;

  UsersNavigationResponse({this.Id, this.Name, this.dtoPhone});

  factory UsersNavigationResponse.fromJson(Map<String, dynamic> json) {
    return UsersNavigationResponse(
      Id: json['id'],
      Name: json['name'],
      dtoPhone: json['dtoPhone'] != null
          ? DtoPhone.fromJson(json['dtoPhone'])
          : null,
    );
  }
}
