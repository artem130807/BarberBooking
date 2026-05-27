import 'package:barber_booking_app/config/api_config.dart';
import 'package:signalr_netcore/hub_connection.dart';
import 'package:signalr_netcore/hub_connection_builder.dart';
import 'package:signalr_netcore/http_connection_options.dart';
import 'package:signalr_netcore/itransport.dart';

class SignalRChatService {
  static const _hubPath = '/chatHub';
  static const _methodReceive = 'ReceiveMessage';
  static const _methodDeleted = 'MessageDeleted';
  static const _methodUpdated = 'MessageUpdated';

  HubConnection? _hub;
  String? _token;
  String? _joinedConversationId;

  Future<void> connect(String token) async {
    final t = token.trim();
    if (t.isEmpty) return;

    if (_hub != null &&
        _hub!.state == HubConnectionState.Connected &&
        _token == t) {
      return;
    }

    await disconnect();
    _token = t;

    final hub = HubConnectionBuilder()
        .withUrl(
          _hubUrl(),
          options: HttpConnectionOptions(
            accessTokenFactory: () async => t,
            transport: HttpTransportType.WebSockets,
          ),
        )
        .withAutomaticReconnect()
        .build();

    await hub.start();
    _hub = hub;
  }

  Future<void> joinConversation(
    String conversationId, {
    required Future<void> Function() onMessageEvent,
  }) async {
    final h = _hub;
    if (h == null || h.state != HubConnectionState.Connected) return;

    if (_joinedConversationId == conversationId) return;

    _joinedConversationId = conversationId;

    h.off(_methodReceive);
    h.off(_methodDeleted);
    h.off(_methodUpdated);

    h.on(_methodReceive, (_) {
      onMessageEvent();
    });
    h.on(_methodDeleted, (_) {
      onMessageEvent();
    });
    h.on(_methodUpdated, (_) {
      onMessageEvent();
    });

    await h.invoke(
      'JoinToChat',
      args: ['conversation_$conversationId'],
    );
  }

  Future<void> disconnect() async {
    final h = _hub;
    _hub = null;
    _token = null;
    _joinedConversationId = null;
    if (h != null) {
      try {
        await h.stop();
      } catch (_) {}
    }
  }

  String _hubUrl() {
    final base = kApiBaseUrl.endsWith('/')
        ? kApiBaseUrl.substring(0, kApiBaseUrl.length - 1)
        : kApiBaseUrl;
    return '$base$_hubPath';
  }
}

