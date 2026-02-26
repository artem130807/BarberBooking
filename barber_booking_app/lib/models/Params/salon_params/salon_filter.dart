import 'package:barber_booking_app/models/base/json_serializable.dart';

class SalonSearchFilter extends JsonSerializable {
  bool? IsActive;
  double? MinRating;
  double? MaxRating;

  SalonSearchFilter({this.IsActive ,this.MinRating, this.MaxRating});
  
  @override
  Map<String, dynamic> toJson() {
    return{
      'isActive':IsActive,
      'minRating':MinRating,
      'maxRating':MaxRating
    };
  }
}