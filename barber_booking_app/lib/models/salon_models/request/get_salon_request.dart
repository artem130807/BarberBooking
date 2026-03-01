import 'package:barber_booking_app/models/base/json_serializable.dart';

class GetSalonRequest extends JsonSerializable{
  String? Id;
  GetSalonRequest({this.Id});
  
  @override
  Map<String, dynamic> toJson() {
      return{
        'id':Id
      };
  }
}