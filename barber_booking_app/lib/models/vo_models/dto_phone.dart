import 'package:barber_booking_app/models/base/json_serializable.dart';

class DtoPhone extends JsonSerializable{
  final String Number;
  DtoPhone({required this.Number});
  
  @override
  Map<String, dynamic> toJson() {
    return{
        'number':Number,
    };
  }
  factory DtoPhone.fromJson(Map<String, dynamic> json) {
    final n = json['number'] ?? json['Number'];
    return DtoPhone(
      Number: n?.toString() ?? '',
    );
  }
}