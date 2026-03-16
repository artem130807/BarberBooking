import 'package:barber_booking_app/models/base/json_serializable.dart';

class UpdateReviewRequest extends JsonSerializable{
 int? salonRating;
 int? masterRating; 
 String? comment;

UpdateReviewRequest({this.salonRating, this.masterRating, this.comment});

  @override
  Map<String, dynamic> toJson() {
    return{
      'salonRating':salonRating,
      'masterRating':masterRating,
      'comment':comment
    };
  }
  
}