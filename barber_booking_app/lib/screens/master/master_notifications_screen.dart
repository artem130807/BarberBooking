import 'package:barber_booking_app/providers/auth_providers/auth_provider.dart';
import 'package:barber_booking_app/providers/message_providers/get_count_messages_provider.dart';
import 'package:barber_booking_app/providers/message_providers/get_message_user_provider.dart';
import 'package:barber_booking_app/widgets/loading_indicator.dart';
import 'package:barber_booking_app/screens/master/master_navigation.dart';
import 'package:barber_booking_app/widgets/profile_shell_widgets.dart'
    show profileCardShape;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class MasterNotificationsScreen extends StatefulWidget {
  const MasterNotificationsScreen({super.key});

  @override
  State<MasterNotificationsScreen> createState() =>
      _MasterNotificationsScreenState();
}

class _MasterNotificationsScreenState extends State<MasterNotificationsScreen> {
  bool _loadError = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    final token = context.read<AuthProvider>().token;
    final p = context.read<GetMessageUserProvider>();
    setState(() => _loadError = false);
    final ok = await p.loadMessages(token);
    if (!mounted) return;
    if (!ok) {
      setState(() => _loadError = true);
      return;
    }
    await context.read<GetCountMessagesProvider>().loadCount(token);
  }

  String _formatWhen(DateTime d) {
    final local = d.toLocal();
    return DateFormat('dd.MM.yyyy · HH:mm').format(local);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    return MasterScreenScaffold(
      selectedTabIndex: MasterNav.today,
      appBar: AppBar(
        title: const Text('Уведомления'),
      ),
      body: Consumer<GetMessageUserProvider>(
        builder: (context, provider, _) {
          if (_loadError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Не удалось загрузить уведомления',
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
            );
          }

          if (provider.isLoading && provider.messages.isEmpty) {
            return const Center(
                child: LoadingIndicator(message: 'Загрузка…'));
          }

          if (provider.messages.isEmpty) {
            return RefreshIndicator(
              onRefresh: _load,
              child: ListView(
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
                            color: cs.onSurfaceVariant.withValues(alpha: 0.45),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Уведомлений пока нет',
                            style: TextStyle(color: cs.onSurfaceVariant),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _load,
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              itemCount: provider.messages.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, i) {
                final m = provider.messages[i];
                return Dismissible(
                  key: ValueKey<String>(m.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 24),
                    decoration: BoxDecoration(
                      color: cs.error,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Icon(
                          Icons.delete_outline_rounded,
                          color: cs.onError,
                          size: 26,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Удалить',
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: cs.onError,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  confirmDismiss: (_) async {
                    final token = context.read<AuthProvider>().token;
                    final messenger = ScaffoldMessenger.maybeOf(context);
                    final err =
                        await provider.deleteMessage(token, m.id);
                    if (!context.mounted) return false;
                    if (err != null) {
                      HapticFeedback.mediumImpact();
                      messenger?.showSnackBar(
                        SnackBar(
                          content: Text(err),
                          behavior: SnackBarBehavior.floating,
                          margin: const EdgeInsets.fromLTRB(16, 0, 16, 88),
                        ),
                      );
                      return false;
                    }
                    HapticFeedback.lightImpact();
                    await context
                        .read<GetCountMessagesProvider>()
                        .loadCount(token);
                    return true;
                  },
                  child: Card(
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
                              color: cs.primaryContainer.withValues(alpha: 0.65),
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
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  m.content,
                                  style: theme.textTheme.bodyLarge?.copyWith(
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
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
