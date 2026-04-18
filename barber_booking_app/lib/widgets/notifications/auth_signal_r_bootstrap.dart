import 'package:barber_booking_app/providers/auth_providers/auth_provider.dart';
import 'package:barber_booking_app/providers/message_providers/get_count_messages_provider.dart';
import 'package:barber_booking_app/services/realtime/signalr_notification_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AuthSignalRBootstrap extends StatefulWidget {
  const AuthSignalRBootstrap({required this.child, super.key});

  final Widget child;

  @override
  State<AuthSignalRBootstrap> createState() => _AuthSignalRBootstrapState();
}

class _AuthSignalRBootstrapState extends State<AuthSignalRBootstrap> {
  late final AuthProvider _auth;

  @override
  void initState() {
    super.initState();
    _auth = context.read<AuthProvider>();
    _auth.addListener(_sync);
    WidgetsBinding.instance.addPostFrameCallback((_) => _sync());
  }

  @override
  void dispose() {
    _auth.removeListener(_sync);
    super.dispose();
  }

  Future<void> _onAfterSignalR() async {
    if (!mounted) return;
    await context.read<GetCountMessagesProvider>().loadCount();
  }

  void _sync() {
    Future<void> run() async {
      final auth = _auth;
      final svc = context.read<SignalRNotificationService>();
      final token = await auth.ensureValidAccessToken();
      if (!mounted) return;
      if (auth.isAuthenticated && token != null && token.isNotEmpty) {
        svc.setOnAfterReceive(() {
          _onAfterSignalR();
        });
        svc.connectIfNeeded(token);
      } else {
        svc.setOnAfterReceive(null);
        svc.disconnect();
      }
    }

    Future.microtask(run);
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
