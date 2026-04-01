import 'package:barber_booking_app/providers/auth_providers/auth_provider.dart';
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

  void _sync() {
    final auth = _auth;
    final svc = context.read<SignalRNotificationService>();
    final token = auth.token;
    if (auth.isAuthenticated && token != null && token.isNotEmpty) {
      svc.connectIfNeeded(token);
    } else {
      svc.disconnect();
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
