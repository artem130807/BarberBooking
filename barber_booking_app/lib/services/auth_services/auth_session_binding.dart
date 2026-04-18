class AuthSessionBinding {
  AuthSessionBinding._();

  static final AuthSessionBinding instance = AuthSessionBinding._();

  Future<String?> Function()? _accessToken;

  void attach(Future<String?> Function() accessToken) {
    _accessToken = accessToken;
  }

  Future<String?> accessToken() async =>
      _accessToken != null ? await _accessToken!() : null;
}
