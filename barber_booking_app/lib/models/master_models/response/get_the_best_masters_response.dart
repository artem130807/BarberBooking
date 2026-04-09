
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
    final ratingRaw = json['rating'] ?? json['Rating'];
    return GetTheBestMastersResponse(
      Id: (json['id'] ?? json['Id'])?.toString(),
      AvatarUrl: json['avatarUrl'] as String? ?? json['AvatarUrl'] as String?,
      UserName: json['userName'] as String? ?? json['UserName'] as String?,
      Rating: ratingRaw is num ? ratingRaw.toDouble() : null,
    );
  }
}