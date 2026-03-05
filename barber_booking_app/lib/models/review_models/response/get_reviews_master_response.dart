class GetReviewsMasterResponse{
  String? Id;
  String? UserName;
  int? MasterRating;
  String? Comment;
  String? CreatedAt;

  GetReviewsMasterResponse({this.Id, this.UserName, this.MasterRating, this.Comment, this.CreatedAt});

  factory GetReviewsMasterResponse.fromJson(Map<String, dynamic> json){
    return GetReviewsMasterResponse(
      Id: json['id'],
      UserName: json['userName'],
      MasterRating: json['masterRating'],
      Comment: json['comment'],
      CreatedAt: json['createdAt']
    );
  }
}