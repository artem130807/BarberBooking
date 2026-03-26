import 'package:barber_booking_app/models/base/json_serializable.dart';

class ReviewSortParams extends JsonSerializable{
  bool? OrderBy;
  bool? OrderbyDescending;
  
  ReviewSortParams({this.OrderBy, this.OrderbyDescending});

  @override
  Map<String, dynamic> toJson() {
    return{
      'OrderBy': OrderBy,
      'OrderbyDescending': OrderbyDescending,
    };
  }
}