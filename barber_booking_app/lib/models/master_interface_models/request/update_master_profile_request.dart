import 'package:barber_booking_app/models/base/json_serializable.dart';

class UpdateMasterProfileRequest extends JsonSerializable {
  String? Bio;
  String? Specialization;
  String? AvatarUrl;

  UpdateMasterProfileRequest({
    this.Bio,
    this.Specialization,
    this.AvatarUrl,
  });

  @override
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (Bio != null) map['bio'] = Bio;
    if (Specialization != null) map['specialization'] = Specialization;
    if (AvatarUrl != null) map['avatarUrl'] = AvatarUrl;
    return map;
  }
}
