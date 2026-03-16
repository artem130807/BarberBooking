import 'package:barber_booking_app/models/base/json_serializable.dart';

class CreateReviewRequest extends JsonSerializable {
  String? AppointmentId;
  String? SalonId;
  String? MasterProfileId;
  int? SalonRating;
  int? MasterRating;
  String? Comment;
  CreateReviewRequest({this.AppointmentId, this.SalonId, this.MasterProfileId, this.SalonRating, this.MasterRating, this.Comment});
  
  @override
  Map<String, dynamic> toJson() {
    return{
      'appointmentId':AppointmentId,
      'salonId':SalonId,
      'masterProfileId':MasterProfileId,
      'salonRating':SalonRating,
      'masterRating':MasterRating,
      'comment':Comment
    };
  }

}