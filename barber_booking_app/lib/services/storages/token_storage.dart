import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorage {
  static const _keyAccessToken = 'access_token';
  static const _keyRefreshToken = 'refresh_token';
  static const _keyRoleInterface = 'role_interface';
  static const _keyDeviceId = 'device_id';
  static const _keyDevicesPayload = 'devices_payload';
  static const _keyLastRegisteredFcmToken = 'last_registered_fcm_token';

  final FlutterSecureStorage _storage;

  TokenStorage({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  static String _platformSlug() {
    if (kIsWeb) return 'web';
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 'android';
      case TargetPlatform.iOS:
        return 'ios';
      case TargetPlatform.linux:
        return 'linux';
      case TargetPlatform.macOS:
        return 'macos';
      case TargetPlatform.windows:
        return 'windows';
      default:
        return 'unknown';
    }
  }

  Future<String> getOrCreateDeviceId() async {
    final existing = await _storage.read(key: _keyDeviceId);
    if (existing != null && existing.isNotEmpty) {
      return existing;
    }
    await sessionDevicePayload();
    final id = await _storage.read(key: _keyDeviceId);
    return id ?? '';
  }

  Future<String> sessionDevicePayload() async {
    final stored = await _storage.read(key: _keyDevicesPayload);
    if (stored != null && stored.isNotEmpty) {
      return stored;
    }
    final legacy = await _storage.read(key: _keyDeviceId);
    if (legacy != null && legacy.isNotEmpty) {
      await _storage.write(key: _keyDevicesPayload, value: legacy);
      return legacy;
    }
    final rnd = Random.secure();
    final bytes = List<int>.generate(16, (_) => rnd.nextInt(256));
    final id = bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
    final payload = '${_platformSlug()}|$id';
    await _storage.write(key: _keyDeviceId, value: id);
    await _storage.write(key: _keyDevicesPayload, value: payload);
    return payload;
  }

  Future<void> saveAuthSession({
    required String accessToken,
    String? refreshToken,
    int? roleInterface,
    bool replaceRefreshIfNull = false,
  }) async {
    await _storage.write(key: _keyAccessToken, value: accessToken);
    if (refreshToken != null && refreshToken.isNotEmpty) {
      await _storage.write(key: _keyRefreshToken, value: refreshToken);
    } else if (replaceRefreshIfNull) {
      await _storage.delete(key: _keyRefreshToken);
    }
    if (roleInterface != null) {
      await _storage.write(key: _keyRoleInterface, value: '$roleInterface');
    }
  }

  Future<String?> getAccessToken() async => _storage.read(key: _keyAccessToken);

  Future<String?> getRefreshToken() async => _storage.read(key: _keyRefreshToken);

  Future<int?> getRoleInterface() async {
    final s = await _storage.read(key: _keyRoleInterface);
    if (s == null || s.isEmpty) return null;
    return int.tryParse(s);
  }

  Future<String?> getLastRegisteredFcmToken() async =>
      _storage.read(key: _keyLastRegisteredFcmToken);

  Future<void> setLastRegisteredFcmToken(String token) async {
    await _storage.write(key: _keyLastRegisteredFcmToken, value: token);
  }

  Future<void> clearLastRegisteredFcmToken() async {
    await _storage.delete(key: _keyLastRegisteredFcmToken);
  }

  Future<void> clearAuthTokens() async {
    await _storage.delete(key: _keyAccessToken);
    await _storage.delete(key: _keyRefreshToken);
    await _storage.delete(key: _keyRoleInterface);
    await _storage.delete(key: _keyLastRegisteredFcmToken);
  }

  Future<bool> hasAccessToken() async {
    final t = await getAccessToken();
    return t != null && t.isNotEmpty;
  }
}
