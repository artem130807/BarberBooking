class GetMastersResponse {
  String? Id;
  String? UserName;
  String? Specialization;
  String? AvatarUrl;
  double? Rating;
  int? RatingCount;
  String? SalonId;

  GetMastersResponse({this.Id, this.UserName, this.Specialization, this.AvatarUrl, this.Rating, this.RatingCount, this.SalonId});

    factory GetMastersResponse.fromJson(Map<String, dynamic> json){
    return  GetMastersResponse(
        Id: json['id'],
        UserName: json['userName'],
        Specialization: json['specialization'],
        AvatarUrl: json['avatarUrl'],
        Rating: json['rating'],
        RatingCount: json['ratingCount'],
        SalonId: json['salonId']
    );
  }
}