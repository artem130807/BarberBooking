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
    dynamic v(String a, String b) => json[a] ?? json[b];
    return MasterProfileInfoAdminResponse(
      Id: v('id', 'Id')?.toString(),
      UserName: v('userName', 'UserName')?.toString(),
      Bio: v('bio', 'Bio')?.toString(),
      Specialization: v('specialization', 'Specialization')?.toString(),
      AvatarUrl: v('avatarUrl', 'AvatarUrl')?.toString(),
      Rating: _toDouble(v('rating', 'Rating')),
      RatingCount: _toInt(v('ratingCount', 'RatingCount')),
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
