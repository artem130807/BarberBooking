import 'package:barber_booking_app/models/base/json_serializable.dart';

class MasterFilter extends JsonSerializable {
  bool? MaxRating;
  bool? Popular;
  MasterFilter({this.MaxRating, this.Popular});

  @override
  Map<String, dynamic> toJson() {
    return{
      'maxRating':MaxRating,
      'popular':Popular
    };
  }
  
}