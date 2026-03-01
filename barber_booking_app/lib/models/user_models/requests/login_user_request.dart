class LoginUserRequest{
    String? email;
    String? passwordHash;

    LoginUserRequest({this.email, this.passwordHash});
    Map<String, dynamic> toJson() => {
        'email': email,
        'passwordHash': passwordHash,
    };
}