/// Соответствует [DtoUserProfile] с API `get_user_profile/{id}`.
class UserProfileByIdResponse {
  UserProfileByIdResponse({
    this.id,
    this.name,
    this.email,
    this.phone,
  });

  String? id;
  String? name;
  String? email;
  UserPhoneDto? phone;

  factory UserProfileByIdResponse.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic>? phoneMap;
    final rawPhone = json['phone'] ?? json['Phone'];
    if (rawPhone is Map) {
      phoneMap = Map<String, dynamic>.from(rawPhone);
    }
    return UserProfileByIdResponse(
      id: json['id']?.toString() ?? json['Id']?.toString(),
      name: json['name'] as String? ?? json['Name'] as String?,
      email: json['email'] as String? ?? json['Email'] as String?,
      phone: phoneMap != null ? UserPhoneDto.fromJson(phoneMap) : null,
    );
  }
}

class UserPhoneDto {
  UserPhoneDto({this.number});

  String? number;

  factory UserPhoneDto.fromJson(Map<String, dynamic> json) {
    return UserPhoneDto(
      number: json['number'] as String? ?? json['Number'] as String?,
    );
  }
}
