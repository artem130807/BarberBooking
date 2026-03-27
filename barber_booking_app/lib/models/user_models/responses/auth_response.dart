class AuthResponse {
  final String? token;
  final String? message;
  final int? roleInterface;

  AuthResponse({
    this.token,
    this.message,
    this.roleInterface,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      token: json['token'] as String? ?? json['Token'] as String?,
      message: json['message'] as String? ?? json['Message'] as String?,
      roleInterface: _parseInt(json['roleInterface'] ?? json['RoleInterface']),
    );
  }

  static int? _parseInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v);
    return null;
  }
}
