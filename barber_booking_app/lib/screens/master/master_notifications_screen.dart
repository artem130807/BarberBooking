import 'package:barber_booking_app/models/messages_models/response/get_messages_user_response.dart';
import 'package:barber_booking_app/providers/auth_providers/auth_provider.dart';
import 'package:barber_booking_app/providers/message_providers/get_count_messages_provider.dart';
import 'package:barber_booking_app/services/messages_services/get_message_user_service.dart';
import 'package:barber_booking_app/widgets/loading_indicator.dart';
import 'package:barber_booking_app/widgets/profile_shell_widgets.dart'
    show profileCardShape;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class MasterNotificationsScreen extends StatefulWidget {
  const MasterNotificationsScreen({super.key});

  @override
  State<MasterNotificationsScreen> createState() =>
      _MasterNotificationsScreenState();
}

class _MasterNotificationsScreenState extends State<MasterNotificationsScreen> {
  final GetMessageUserService _service = GetMessageUserService();
  List<GetMessagesUserResponse> _items = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    final token = context.read<AuthProvider>().token;
    setState(() {
      _loading = true;
      _error = null;
    });
    final list = await _service.getMessages(token);
    if (!mounted) return;
    if (list == null) {
      setState(() {
        _loading = false;
        _error = 'Не удалось загрузить уведомления';
      });
      return;
    }
    setState(() {
      _items = list;
      _loading = false;
    });
    final t = context.read<AuthProvider>().token;
    await context.read<GetCountMessagesProvider>().loadCount(t);
  }

  String _formatWhen(DateTime d) {
    final local = d.toLocal();
    return DateFormat('dd.MM.yyyy · HH:mm').format(local);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Уведомления'),
      ),
      body: _loading
          ? const Center(child: LoadingIndicator(message: 'Загрузка…'))
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _error!,
                          textAlign: TextAlign.center,
                          style: TextStyle(color: cs.onSurfaceVariant),
                        ),
                        const SizedBox(height: 16),
                        FilledButton.tonal(
                          onPressed: _load,
                          child: const Text('Повторить'),
                        ),
                      ],
                    ),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _load,
                  child: _items.isEmpty
                      ? ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: [
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.35,
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.notifications_none_rounded,
                                      size: 56,
                                      color: cs.onSurfaceVariant
                                          .withValues(alpha: 0.45),
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      'Уведомлений пока нет',
                                      style: TextStyle(
                                        color: cs.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                          itemCount: _items.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 10),
                          itemBuilder: (context, i) {
                            final m = _items[i];
                            return Card(
                              margin: EdgeInsets.zero,
                              clipBehavior: Clip.antiAlias,
                              shape: profileCardShape(cs),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: 44,
                                      height: 44,
                                      decoration: BoxDecoration(
                                        color: cs.primaryContainer
                                            .withValues(alpha: 0.65),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Icon(
                                        Icons.notifications_active_rounded,
                                        color: cs.primary,
                                        size: 24,
                                      ),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            m.content,
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyLarge
                                                ?.copyWith(
                                                  height: 1.35,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            _formatWhen(m.createdAt),
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: cs.onSurfaceVariant,
                                            ),
                                          ),
                                        ],
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
