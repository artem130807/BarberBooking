import 'package:barber_booking_app/config/api_config.dart';
import 'package:barber_booking_app/providers/notification_providers/notification_toast_controller.dart';
import 'package:signalr_netcore/hub_connection.dart';
import 'package:signalr_netcore/hub_connection_builder.dart';
import 'package:signalr_netcore/http_connection_options.dart';
import 'package:signalr_netcore/itransport.dart';

class SignalRNotificationService {
  SignalRNotificationService(this._toasts);

  final NotificationToastController _toasts;
  HubConnection? _hub;
  String? _token;

  static const String _hubPath = '/notificationHub';
  static const String _receiveMethod = 'ReceiveNotification';

  Future<void> connectIfNeeded(String token) async {
    final t = token.trim();
    if (t.isEmpty) {
      await disconnect();
      return;
    }
    if (_token == t &&
        _hub != null &&
        _hub!.state == HubConnectionState.Connected) {
      return;
    }
    await disconnect();
    _token = t;
    final url = _hubUrl();
    final hub = HubConnectionBuilder()
        .withUrl(
          url,
          options: HttpConnectionOptions(
            accessTokenFactory: () async => t,
            transport: HttpTransportType.WebSockets,
          ),
        )
        .withAutomaticReconnect()
        .build();
    hub.on(_receiveMethod, _onReceive);
    try {
      await hub.start();
      _hub = hub;
    } catch (_) {
      _hub = null;
      _token = null;
    }
  }

  String _hubUrl() {
    final base = kApiBaseUrl.endsWith('/')
        ? kApiBaseUrl.substring(0, kApiBaseUrl.length - 1)
        : kApiBaseUrl;
    return '$base$_hubPath';
  }

  void _onReceive(List<Object?>? arguments) {
    String? text;
    if (arguments != null && arguments.isNotEmpty) {
      final first = arguments.first;
      if (first is Map) {
        final m = Map<Object?, Object?>.from(first);
        final msg = m['message'] ?? m['Message'];
        if (msg is String) text = msg;
      } else if (first is String) {
        text = first;
      }
    }
    _toasts.push(text ?? 'Новое уведомление');
  }

  Future<void> disconnect() async {
    final h = _hub;
    _hub = null;
    _token = null;
    if (h != null) {
      try {
        await h.stop();
      } catch (_) {}
    }
  }

  void disposeSync() {
    final h = _hub;
    _hub = null;
    _token = null;
    if (h != null) {
      h.stop().catchError((_) {});
    }
  }
}
