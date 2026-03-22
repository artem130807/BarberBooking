class GetMessageUserResponse{
  String? Id;
  String? Content;
  DateTime? CreatedAt;

  GetMessageUserResponse({this.Id, this.Content, this.CreatedAt});
  factory GetMessageUserResponse.fromJson(Map<String, dynamic> json){
    return GetMessageUserResponse(
      Id: json['id'],
      Content: json['content'],
      CreatedAt: json['createdAt']
    );
  }
}