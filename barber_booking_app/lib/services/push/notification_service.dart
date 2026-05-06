import 'dart:async';

import 'package:barber_booking_app/services/push/fcm_token_registration_service.dart';
import 'package:barber_booking_app/services/storages/token_storage.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  static const String _channelId = 'barber_booking_default';
  static const String _channelName = 'BarberBooking';
  static const String _channelDescription =
      'Напоминания о записях и сообщения от салонов и мастеров';

  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  final TokenStorage _tokenStorage = TokenStorage();

  bool _initialized = false;
  StreamSubscription<RemoteMessage>? _onForegroundSub;
  StreamSubscription<RemoteMessage>? _onOpenedAppSub;
  StreamSubscription<String>? _onTokenRefreshSub;

  Future<void> initialize() async {
    if (_initialized) {
      return;
    }

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    await _localNotifications.initialize(
      settings: InitializationSettings(
        android: androidInit,
        iOS: iosInit,
      ),
      onDidReceiveNotificationResponse: _onLocalNotificationTapped,
    );

    await _ensureAndroidChannel();

    final messaging = FirebaseMessaging.instance;

    if (defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.macOS) {
      await messaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
    }

    final settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      if (kDebugMode) {
        debugPrint('NotificationService: разрешение на push-уведомления получено');
      }
      await _syncRegistrationWithBackend();
    } else {
      if (kDebugMode) {
        debugPrint(
          'NotificationService: уведомления отклонены (${settings.authorizationStatus})',
        );
      }
    }

    _onTokenRefreshSub = FirebaseMessaging.instance.onTokenRefresh.listen(
      _onFcmTokenRefreshed,
    );

    _onForegroundSub =
        FirebaseMessaging.onMessage.listen(_showForegroundLocalNotification);
    _onOpenedAppSub =
        FirebaseMessaging.onMessageOpenedApp.listen(_handleRemoteMessageTap);

    await _dispatchInitialMessageIfAny();

    _initialized = true;
  }

  Future<void> syncFcmRegistrationWithBackend() async {
    final access = await _tokenStorage.getAccessToken();
    if (access == null || access.isEmpty) {
      return;
    }
    await _syncRegistrationWithBackend();
  }

  Future<void> unregisterFcmFromBackendIfNeeded() async {
    final last = await _tokenStorage.getLastRegisteredFcmToken();
    if (last == null || last.isEmpty) {
      return;
    }
    final access = await _tokenStorage.getAccessToken();
    if (access == null || access.isEmpty) {
      await _tokenStorage.clearLastRegisteredFcmToken();
      return;
    }
    await FcmTokenRegistrationService.unregister(
      last,
      bearerAccessToken: access,
    );
    await _tokenStorage.clearLastRegisteredFcmToken();
  }

  Future<void> _syncRegistrationWithBackend() async {
    final access = await _tokenStorage.getAccessToken();
    if (access == null || access.isEmpty) {
      return;
    }
    final token = await FirebaseMessaging.instance.getToken();
    if (token == null || token.isEmpty) {
      return;
    }
    final last = await _tokenStorage.getLastRegisteredFcmToken();
    if (last == token) {
      return;
    }
    final ok = await FcmTokenRegistrationService.register(token);
    if (ok == true) {
      await _tokenStorage.setLastRegisteredFcmToken(token);
    }
  }

  Future<void> _onFcmTokenRefreshed(String newToken) async {
    final access = await _tokenStorage.getAccessToken();
    if (access == null || access.isEmpty) {
      return;
    }
    final old = await _tokenStorage.getLastRegisteredFcmToken();
    if (old != null && old.isNotEmpty && old != newToken) {
      await FcmTokenRegistrationService.unregister(
        old,
        bearerAccessToken: access,
      );
    }
    final ok = await FcmTokenRegistrationService.register(newToken);
    if (ok == true) {
      await _tokenStorage.setLastRegisteredFcmToken(newToken);
    }
  }

  Future<void> _ensureAndroidChannel() async {
    final android = _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    if (android == null) {
      return;
    }

    await android.createNotificationChannel(
      const AndroidNotificationChannel(
        _channelId,
        _channelName,
        description: _channelDescription,
        importance: Importance.high,
      ),
    );
  }

  Future<void> _dispatchInitialMessageIfAny() async {
    final initial = await FirebaseMessaging.instance.getInitialMessage();
    if (initial != null) {
      _handleRemoteMessageTap(initial);
    }
  }

  void _onLocalNotificationTapped(NotificationResponse response) {
    if (kDebugMode) {
      debugPrint(
        'NotificationService: нажатие по локальному уведомлению '
        '(payload: ${response.payload})',
      );
    }
  }

  void _showForegroundLocalNotification(RemoteMessage message) {
    final notification = message.notification;
    if (notification == null) {
      return;
    }

    final title = notification.title?.trim();
    final body = notification.body?.trim();

    _localNotifications.show(
      id: _stableNotificationId(message),
      title: (title != null && title.isNotEmpty) ? title : _channelName,
      body: body,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: _channelDescription,
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: const DarwinNotificationDetails(),
      ),
      payload: message.data.isNotEmpty ? message.data.toString() : null,
    );
  }

  void _handleRemoteMessageTap(RemoteMessage message) {
    if (kDebugMode) {
      debugPrint('NotificationService: открыто из push, data=${message.data}');
    }
  }

  int _stableNotificationId(RemoteMessage message) {
    final mid = message.messageId;
    if (mid != null && mid.isNotEmpty) {
      return mid.hashCode & 0x7fffffff;
    }
    return DateTime.now().millisecondsSinceEpoch.remainder(1 << 31);
  }

  Future<void> dispose() async {
    await _onForegroundSub?.cancel();
    await _onOpenedAppSub?.cancel();
    await _onTokenRefreshSub?.cancel();
    _onForegroundSub = null;
    _onOpenedAppSub = null;
    _onTokenRefreshSub = null;
    _initialized = false;
  }
}
