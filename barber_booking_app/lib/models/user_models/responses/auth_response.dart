class AuthResponse {
  final String? accessToken;
  final String? refreshToken;
  final String? message;
  final int? roleInterface;

  AuthResponse({
    this.accessToken,
    this.refreshToken,
    this.message,
    this.roleInterface,
  });

  String? get token => accessToken;

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    final access = _readString(json, const [
      'accessToken',
      'AccessToken',
      'token',
      'Token',
    ]);
    final refresh = _readString(json, const [
      'refreshToken',
      'RefreshToken',
    ]);
    return AuthResponse(
      accessToken: access,
      refreshToken: refresh,
      message: _readString(json, const ['message', 'Message']),
      roleInterface: _parseInt(json['roleInterface'] ?? json['RoleInterface']),
    );
  }

  static String? _readString(Map<String, dynamic> json, List<String> keys) {
    for (final k in keys) {
      final v = json[k];
      if (v is String && v.isNotEmpty) return v;
    }
    return null;
  }

  static int? _parseInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v);
    return null;
  }

  AuthResponse copyWith({
    String? accessToken,
    String? refreshToken,
    String? message,
    int? roleInterface,
  }) {
    return AuthResponse(
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
      message: message ?? this.message,
      roleInterface: roleInterface ?? this.roleInterface,
    );
  }
}
