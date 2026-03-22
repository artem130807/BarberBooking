import 'package:barber_booking_app/models/vo_models/dto_phone.dart';

class UserNavigationResponse {
  String? Id;
  String? Name;
  DtoPhone? Phone;

  UserNavigationResponse({this.Id, this.Name, this.Phone});

  factory UserNavigationResponse.fromJson(Map<String, dynamic> json){
    return UserNavigationResponse(
      Id: json['id'],
      Name: json['name'],
      Phone: json['dtoPhone'] != null ? DtoPhone.fromJson(json['number']): null,
    );
  }
}