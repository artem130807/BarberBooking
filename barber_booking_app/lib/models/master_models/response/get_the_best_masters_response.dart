class GetTheBestMastersResponse {
  String? Id;
  String? AvatarUrl;
  String? UserName;
  GetTheBestMastersResponse({this.Id, this.AvatarUrl, this.UserName});
  
   factory GetTheBestMastersResponse.fromJson(Map<String, dynamic> json){
    return  GetTheBestMastersResponse(
      Id: json['id'],
      AvatarUrl: json['avatarUrl'],
      UserName: json['userName'],  
    );
  }
}