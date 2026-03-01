import 'package:barber_booking_app/models/base/json_serializable.dart';

class SendVerificationRequest extends JsonSerializable {
  String? email;
  SendVerificationRequest({this.email});
  @override
  Map<String, dynamic> toJson() {
      return{
        'email':email
      };
  }

}