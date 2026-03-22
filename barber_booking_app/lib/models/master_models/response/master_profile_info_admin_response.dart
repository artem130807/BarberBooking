class MasterProfileInfoAdminResponse {
  String? Id;
  String? UserName;
  String? Bio;
  String? Specialization;
  String? AvatarUrl;
  double? Rating;
  int? RatingCount;

  MasterProfileInfoAdminResponse({
    this.Id,
    this.UserName,
    this.Bio,
    this.Specialization,
    this.AvatarUrl,
    this.Rating,
    this.RatingCount,
  });

  factory MasterProfileInfoAdminResponse.fromJson(Map<String, dynamic> json) {
    return MasterProfileInfoAdminResponse(
      Id: json['id']?.toString(),
      UserName: json['userName']?.toString(),
      Bio: json['bio']?.toString(),
      Specialization: json['specialization']?.toString(),
      AvatarUrl: json['avatarUrl']?.toString(),
      Rating: _toDouble(json['rating']),
      RatingCount: _toInt(json['ratingCount']),
    );
  }

  static double? _toDouble(dynamic v) {
    if (v == null) return null;
    if (v is double) return v;
    if (v is int) return v.toDouble();
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString());
  }

  static int? _toInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse(v.toString());
  }
}
