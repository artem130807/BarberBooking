import 'package:barber_booking_app/models/base/json_serializable.dart';

class DtoPhone extends JsonSerializable{
  final String number;
  DtoPhone({required this.number});
  
  @override
  Map<String, dynamic> toJson() {
    return{
        'number':number,
    };
  }
}