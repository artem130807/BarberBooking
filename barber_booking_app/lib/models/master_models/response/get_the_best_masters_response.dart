
class GetTheBestMastersResponse {
  String? Id;
  String? AvatarUrl;
  String? UserName;
  double? Rating;

  GetTheBestMastersResponse({
    this.Id,
    this.AvatarUrl,
    this.UserName,
    this.Rating,
  });

  factory GetTheBestMastersResponse.fromJson(Map<String, dynamic> json) {
    return GetTheBestMastersResponse(
      Id: json['id']?.toString(),
      AvatarUrl: json['avatarUrl'] as String?,
      UserName: json['userName'] as String?,
      Rating: (json['rating'] as num?)?.toDouble(),
    );
  }
}