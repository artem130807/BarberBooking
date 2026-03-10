import 'package:barber_booking_app/models/base/json_serializable.dart';
class SalonFilter extends JsonSerializable {
  bool? IsActive;
  bool? MaxRating;
  bool? Popular;
  bool? MinPrice; 
  SalonFilter({this.IsActive , this.MaxRating, this.Popular, this.MinPrice});
  
  @override
  Map<String, dynamic> toJson() {
    return{
      'isActive':IsActive,
      'maxRating':MaxRating,
      'popular':Popular,
      'minPrice':MinPrice
    };
  }
}