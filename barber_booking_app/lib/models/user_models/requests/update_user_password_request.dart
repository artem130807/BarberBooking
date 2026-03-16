import 'package:barber_booking_app/models/base/json_serializable.dart';

class UpdateUserPasswordRequest extends JsonSerializable {
  String? Email;
  String? PasswordHash;
  UpdateUserPasswordRequest({this.Email, this.PasswordHash});
  @override
  Map<String, dynamic> toJson() {
    return{
      'email':Email,
      'passwordHash':PasswordHash
    };
  }
}