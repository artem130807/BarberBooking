import 'package:barber_booking_app/models/base/json_serializable.dart';

class UpdatePasswordRequest extends JsonSerializable{
  String? email;
  String? passwordHash;
  UpdatePasswordRequest({this.email, this.passwordHash});
  
  @override
  Map<String, dynamic> toJson() {
      return{
        'email':email,
        'passwordHash':passwordHash
      };
  }

}