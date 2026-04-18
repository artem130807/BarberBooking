import 'package:barber_booking_app/models/base/json_serializable.dart';
import 'package:barber_booking_app/models/vo_models/dto_phone.dart';

class RegisterUserRequest extends JsonSerializable {
  String? name;
  DtoPhone? phone;
  String? email;
  String? password;
  String? city;
  String? devices;

  RegisterUserRequest({
    this.name,
    this.phone,
    this.email,
    this.password,
    this.city,
    this.devices,
  });

  @override
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'phone': phone?.toJson(),
      'email': email,
      'passwordHash': password,
      'city': city,
      'devices': devices,
    };
  }
}
