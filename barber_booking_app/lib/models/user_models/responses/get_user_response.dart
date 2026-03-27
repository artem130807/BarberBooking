class GetUserResponse {
    String? Id;
    String? Name;
    String? Email;   
    String? City;

    GetUserResponse({this.Id, this.Name, this.Email, this.City});
    factory GetUserResponse.fromJson(Map<String, dynamic> json){
      return GetUserResponse(
        Id: json['id'] as String? ?? json['Id'] as String?,
        Name: json['name'] as String? ?? json['Name'] as String?,
        Email: json['email'] as String? ?? json['Email'] as String?,
        City: json['city'] as String? ?? json['City'] as String?,
      );
    }
}