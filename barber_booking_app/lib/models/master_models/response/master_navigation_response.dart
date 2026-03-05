class MasterNavigationResponse {
  String? Id;
  String? MasterName;

  MasterNavigationResponse({this.Id, this.MasterName});
  factory MasterNavigationResponse.fromJson(Map<String, dynamic> json){
    return  MasterNavigationResponse(
      Id: json['id'],
      MasterName: json['masterName'],  
    );
  }
}