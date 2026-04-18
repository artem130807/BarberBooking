class LoginUserRequest {
  String? email;
  String? passwordHash;
  String? devices;

  LoginUserRequest({this.email, this.passwordHash, this.devices});

  Map<String, dynamic> toJson() => {
        'email': email,
        'passwordHash': passwordHash,
        'devices': devices,
      };
}