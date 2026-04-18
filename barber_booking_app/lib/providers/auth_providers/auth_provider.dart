import 'package:barber_booking_app/models/user_models/requests/update_password_request.dart';
import 'package:barber_booking_app/models/user_models/responses/update_password_response.dart';
import 'package:barber_booking_app/services/storages/token_storage.dart';
import 'package:barber_booking_app/utils/admin_last_salon_storage.dart';
import 'package:barber_booking_app/services/auth_services/auth_service.dart';
import 'package:barber_booking_app/services/auth_services/auth_session_binding.dart';
import 'package:barber_booking_app/services/auth_services/refresh_access_token_service.dart';
import 'package:barber_booking_app/services/push/notification_service.dart';
import 'package:barber_booking_app/utils/jwt_expiry.dart';
import 'package:barber_booking_app/models/user_models/requests/login_user_request.dart';
import 'package:barber_booking_app/models/user_models/requests/register_user_request.dart';
import 'package:barber_booking_app/models/user_models/responses/auth_response.dart';
import '../../models/base/base_provider.dart';

class AuthProvider extends BaseProvider {
  AuthProvider({TokenStorage? tokenStorage})
      : _tokenStorage = tokenStorage ?? TokenStorage() {
    AuthSessionBinding.instance.attach(() => ensureValidAccessToken());
  }

  final AuthService _authService = AuthService();
  final TokenStorage _tokenStorage;

  Future<void>? _refreshInFlight;

  AuthResponse? _currentUser;
  bool _isAuthenticated = false;
  String? _verifiedEmail;

  UpdatePasswordResponse? _updatePassword;
  UpdatePasswordResponse? get updatePassword => _updatePassword;
  String? get verifiedEmail => _verifiedEmail;
  AuthResponse? get currentUser => _currentUser;
  bool get isAuthenticated => _isAuthenticated;
  String? get token => _currentUser?.accessToken;
  String? get refreshToken => _currentUser?.refreshToken;
  int? get roleInterface => _currentUser?.roleInterface;

  TokenStorage get tokenStorage => _tokenStorage;

  Future<void> restoreFromStorage() async {
    final access = await _tokenStorage.getAccessToken();
    if (access == null || access.isEmpty) {
      return;
    }
    final refresh = await _tokenStorage.getRefreshToken();
    final role = await _tokenStorage.getRoleInterface();
    _currentUser = AuthResponse(
      accessToken: access,
      refreshToken: refresh,
      roleInterface: role,
    );
    _isAuthenticated = true;
    notifyListeners();
  }

  Future<void> _persistAuthResponse(AuthResponse response) async {
    final access = response.accessToken;
    if (access == null || access.isEmpty) return;
    await _tokenStorage.saveAuthSession(
      accessToken: access,
      refreshToken: response.refreshToken,
      roleInterface: response.roleInterface,
    );
  }

  Future<bool> login(String email, String passwordHash) async {
    startLoading();
    try {
      final devices = await _tokenStorage.sessionDevicePayload();
      final request = LoginUserRequest(
        email: email,
        passwordHash: passwordHash,
        devices: devices,
      );

      final response = await _authService.Login(request);
      if (response != null &&
          response.accessToken != null &&
          response.accessToken!.isNotEmpty) {
        final storedRefresh = await _tokenStorage.getRefreshToken();
        final effectiveRefresh = (response.refreshToken != null &&
                response.refreshToken!.isNotEmpty)
            ? response.refreshToken
            : storedRefresh;
        final merged = AuthResponse(
          accessToken: response.accessToken,
          refreshToken: effectiveRefresh,
          message: response.message,
          roleInterface: response.roleInterface,
        );
        _currentUser = merged;
        _isAuthenticated = true;
        await _persistAuthResponse(merged);
        finishLoading();
        notifyListeners();
        await NotificationService.instance.syncFcmRegistrationWithBackend();
        return true;
      } else {
        setError(response?.message ?? 'Неверная почта или пароль');
        finishLoading();
        return false;
      }
    } catch (e) {
      handleError('Ошибка соединения с сервером');
      finishLoading();
      return false;
    }
  }

  Future<bool> register(RegisterUserRequest request) async {
    startLoading();
    try {
      final devices = await _tokenStorage.sessionDevicePayload();
      request.devices = devices;

      final response = await _authService.Register(request);

      if (response != null &&
          response.accessToken != null &&
          response.accessToken!.isNotEmpty) {
        _currentUser = response;
        _isAuthenticated = true;
        await _persistAuthResponse(response);
        finishLoading();
        notifyListeners();
        await NotificationService.instance.syncFcmRegistrationWithBackend();
        return true;
      } else {
        setError(response?.message ?? 'Неверная почта или пароль');
        finishLoading();
        return false;
      }
    } catch (e) {
      handleError('Ошибка соединения с сервером');
      finishLoading();
      return false;
    }
  }

  Future<bool> updatePass(UpdatePasswordRequest request) async {
    startLoading();
    try {
      final response = await _authService.UpdatePassword(request);

      if (response != null && response.isSuccess == true) {
        _updatePassword = response;
        _isAuthenticated = true;
        finishLoading();
        notifyListeners();
        return true;
      } else {
        setError(response?.message ?? 'Неверная почта или пароль');
        finishLoading();
        return false;
      }
    } catch (e) {
      handleError('Ошибка соединения с сервером');
      finishLoading();
      return false;
    }
  }

  Future<void> logout() async {
    await NotificationService.instance.unregisterFcmFromBackendIfNeeded();
    _currentUser = null;
    _isAuthenticated = false;
    resetState();
    AdminLastSalonStorage.clear();
    await _tokenStorage.clearAuthTokens();
    notifyListeners();
  }

  Future<void> updateToken(String newToken) async {
    if (newToken.isEmpty) return;
    final refresh =
        _currentUser?.refreshToken ?? await _tokenStorage.getRefreshToken();
    final role =
        _currentUser?.roleInterface ?? await _tokenStorage.getRoleInterface();
    _currentUser = AuthResponse(
      accessToken: newToken,
      refreshToken: refresh,
      roleInterface: role,
      message: _currentUser?.message,
    );
    await _tokenStorage.saveAuthSession(
      accessToken: newToken,
      refreshToken: refresh,
      roleInterface: role,
    );
    notifyListeners();
  }

  bool isTokenValid() {
    return token != null &&
        token!.isNotEmpty &&
        !JwtExpiry.isAccessTokenExpired(token!);
  }

  Future<String?> ensureValidAccessToken() async {
    final t = token;
    if (t == null || t.isEmpty) return null;
    if (!JwtExpiry.isAccessTokenExpired(t)) return t;
    if (_refreshInFlight != null) {
      await _refreshInFlight;
      return token;
    }
    final future = _performRefresh();
    _refreshInFlight = future;
    try {
      await future;
    } finally {
      _refreshInFlight = null;
    }
    return token;
  }

  Future<void> _performRefresh() async {
    final refresh = await _tokenStorage.getRefreshToken();
    if (refresh == null || refresh.isEmpty) {
      await logout();
      return;
    }
    final devices = await _tokenStorage.sessionDevicePayload();
    final revoked =
        await RefreshAccessTokenService.isRefreshTokenRevoked(refresh);
    if (revoked == true) {
      await logout();
      return;
    }
    final response = await RefreshAccessTokenService.refreshAccessToken(
      refresh,
      devices,
    );
    if (response == null ||
        response.accessToken == null ||
        response.accessToken!.isEmpty) {
      await logout();
      return;
    }
    final role = response.roleInterface ??
        _currentUser?.roleInterface ??
        await _tokenStorage.getRoleInterface();
    final merged = AuthResponse(
      accessToken: response.accessToken,
      refreshToken: refresh,
      message: response.message,
      roleInterface: role,
    );
    _currentUser = merged;
    _isAuthenticated = true;
    await _persistAuthResponse(merged);
    notifyListeners();
  }

  void setVerifiedEmail(String email) {
    _verifiedEmail = email;
    notifyListeners();
  }

  void clearVerifiedEmail() {
    _verifiedEmail = null;
    notifyListeners();
  }
}
