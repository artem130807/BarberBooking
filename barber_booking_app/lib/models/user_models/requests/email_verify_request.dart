import 'package:barber_booking_app/models/base/json_serializable.dart';

class EmailVerifyRequest extends JsonSerializable {
  String? code;
  EmailVerifyRequest({this.code});

  @override
  Map<String, dynamic> toJson() {
      return{
        'code':code
      };
  }
}