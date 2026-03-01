class GetMasterResponse {
  String? Id;
  String? UserName;
  String? Bio;
  String? Specialization;
  String? AvatarUrl;
  double? Rating;
  int? RatingCount;

  GetMasterResponse({this.Id, this.UserName, this.Bio, this.Specialization, this.AvatarUrl, this.Rating, this.RatingCount});
  factory GetMasterResponse.fromJson(Map<String, dynamic> json){
    return GetMasterResponse(
       Id: json['id'],
        UserName: json['userName'],
        Bio: json['bio'],
        Specialization: json['specialization'],
        AvatarUrl: json['avatarUrl'],
        Rating: json['rating'],
        RatingCount: json['ratingCount']
    );
  }
}