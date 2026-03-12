class GetUserResponse {
    String? Id;
    String? Name;
    String? Email;   
    String? City;

    GetUserResponse({this.Id, this.Name, this.Email, this.City});
    factory GetUserResponse.fromJson(Map<String, dynamic> json){
      return GetUserResponse(
        Id: json['id'],
        Name: json['name'],
        Email: json['email'],
        City: json['city']
      );
    }
}