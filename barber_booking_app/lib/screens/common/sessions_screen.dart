import 'package:barber_booking_app/models/auth_models/refresh_token_session.dart';
import 'package:barber_booking_app/navigation/role_routes.dart';
import 'package:barber_booking_app/providers/auth_providers/auth_provider.dart';
import 'package:barber_booking_app/services/auth_services/refresh_sessions_service.dart';
import 'package:barber_booking_app/utils/device_session_label.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SessionsRouteArgs {
  const SessionsRouteArgs({this.adminUserId});

  final String? adminUserId;
}

class SessionsScreen extends StatefulWidget {
  const SessionsScreen({super.key, this.adminUserId});

  final String? adminUserId;

  @override
  State<SessionsScreen> createState() => _SessionsScreenState();
}

class _SessionsScreenState extends State<SessionsScreen> {
  final RefreshSessionsService _service = RefreshSessionsService();
  List<RefreshTokenSession> _items = [];
  bool _loading = true;
  String? _error;
  String? _localDevicePayload;

  bool get _isAdminView =>
      widget.adminUserId != null && widget.adminUserId!.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    final auth = context.read<AuthProvider>();
    final payload = await auth.tokenStorage.sessionDevicePayload();
    if (mounted) {
      setState(() {
        _localDevicePayload = payload;
      });
    }
    await _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final auth = context.read<AuthProvider>();
    final role = auth.roleInterface;
    final uid = widget.adminUserId;
    final list = await _service.listSessions(
      forUserId: (role == RoleRoutes.adminRole && uid != null && uid.isNotEmpty)
          ? uid
          : null,
    );
    if (!mounted) return;
    if (list == null) {
      setState(() {
        _loading = false;
        _error = 'Не удалось загрузить список сессий';
      });
      return;
    }
    setState(() {
      _items = list;
      _loading = false;
    });
  }

  bool _isCurrent(RefreshTokenSession s) =>
      _localDevicePayload != null &&
      _localDevicePayload!.isNotEmpty &&
      s.devices == _localDevicePayload;

  Future<void> _onRevokeOne(RefreshTokenSession s) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Завершить сессию?'),
        content: Text(
          _isCurrent(s)
              ? 'Вы выйдете из аккаунта на этом устройстве.'
              : 'Выбранное устройство будет разлогинено.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Отмена'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Завершить'),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    final res = await _service.revokeSession(s.id);
    if (!mounted) return;
    if (res != true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Не удалось завершить сессию'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    if (_isCurrent(s)) {
      await context.read<AuthProvider>().logout();
      if (!mounted) return;
      Navigator.of(context).pushNamedAndRemoveUntil('/login', (r) => false);
      return;
    }
    await _load();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Сессия завершена'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _onRevokeAll() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Завершить все сессии?'),
        content: Text(
          _isAdminView
              ? 'Все активные сессии этого пользователя будут завершены.'
              : 'Все устройства будут разлогинены, включая текущее.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Отмена'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Завершить все'),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    final auth = context.read<AuthProvider>();
    bool? res;
    if (_isAdminView && widget.adminUserId != null) {
      res = await _service.revokeAllSessionsForUser(widget.adminUserId!);
    } else {
      res = await _service.revokeAllOwnSessions();
    }
    if (!mounted) return;
    if (res != true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Операция не выполнена'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    if (!_isAdminView) {
      await auth.logout();
      if (!mounted) return;
      Navigator.of(context).pushNamedAndRemoveUntil('/login', (r) => false);
      return;
    }
    await _load();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Все сессии пользователя завершены'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final title = _isAdminView
        ? 'Сессии пользователя'
        : 'Активные сессии';

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          if (!_loading && _items.isNotEmpty)
            TextButton(
              onPressed: _onRevokeAll,
              child: Text(
                'Завершить все',
                style: TextStyle(color: cs.error),
              ),
            ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _error!,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: cs.onSurfaceVariant),
                      ),
                      const SizedBox(height: 16),
                      FilledButton(
                        onPressed: _load,
                        child: const Text('Повторить'),
                      ),
                    ],
                  ),
                )
              : _items.isEmpty
                  ? Center(
                      child: Text(
                        'Нет активных сессий',
                        style: TextStyle(color: cs.onSurfaceVariant),
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _load,
                      child: ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
                        itemCount: _items.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (context, i) {
                          final s = _items[i];
                          final current = _isCurrent(s);
                          return Card(
                            elevation: 0,
                            color: cs.surfaceContainerHighest,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                              side: BorderSide(
                                color: current
                                    ? cs.primary.withValues(alpha: 0.45)
                                    : cs.outlineVariant,
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 10,
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(
                                    Icons.devices_rounded,
                                    color: cs.primary,
                                    size: 26,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        if (current)
                                          Padding(
                                            padding: const EdgeInsets.only(
                                              bottom: 6,
                                            ),
                                            child: Chip(
                                              label: const Text('Это устройство'),
                                              visualDensity:
                                                  VisualDensity.compact,
                                              padding: EdgeInsets.zero,
                                              labelStyle: TextStyle(
                                                fontSize: 12,
                                                color: cs.primary,
                                                fontWeight: FontWeight.w600,
                                              ),
                                              side: BorderSide(
                                                color: cs.primary
                                                    .withValues(alpha: 0.35),
                                              ),
                                            ),
                                          ),
                                        Text(
                                          formatSessionDeviceLabel(s.devices),
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleSmall
                                              ?.copyWith(
                                                fontWeight: FontWeight.w600,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    tooltip: 'Завершить сессию',
                                    onPressed: () => _onRevokeOne(s),
                                    icon: Icon(
                                      Icons.logout_rounded,
                                      color: cs.error,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
    );
  }
}
