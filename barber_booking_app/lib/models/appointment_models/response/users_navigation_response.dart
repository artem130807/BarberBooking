class UsersNavigationResponse {
  String? Id;
  String? Name;

  UsersNavigationResponse({this.Id, this.Name});

  factory UsersNavigationResponse.fromJson(Map<String, dynamic> json) {
    return UsersNavigationResponse(
      Id: json['id']?.toString(),
      Name: json['name'],
    );
  }
}
