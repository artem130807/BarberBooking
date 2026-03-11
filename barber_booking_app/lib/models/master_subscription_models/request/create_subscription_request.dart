import 'package:barber_booking_app/models/base/json_serializable.dart';

class CreateSubscriptionRequest extends JsonSerializable {
  String? MasterId;
  CreateSubscriptionRequest({this.MasterId});
  @override
  Map<String, dynamic> toJson() {
    return{
      'masterId':MasterId
    };
  }
}