
class AuthResponse{
    final String? token;
    final String? message;
    final int? roleInterface;
    AuthResponse({
    this.token,
    this.message,
    this.roleInterface
    });

    factory AuthResponse.fromJson(Map<String, dynamic> json) {
    final rawRole = json['roleInterface'];
    int? roleInterface;
    if (rawRole is int) {
      roleInterface = rawRole;
    } else if (rawRole is num) {
      roleInterface = rawRole.toInt();
    }
    return AuthResponse(
      token: json['token'] as String?,
      message: json['message'] as String?,
      roleInterface: roleInterface,
    );
  }
}
