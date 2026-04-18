import 'package:barber_booking_app/providers/auth_providers/auth_provider.dart';
import 'package:barber_booking_app/providers/message_providers/get_count_messages_provider.dart';
import 'package:barber_booking_app/providers/message_providers/get_message_user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final token = Provider.of<AuthProvider>(context, listen: false).token;
      await Provider.of<GetMessageUserProvider>(context, listen: false)
          .loadMessages();

      if (mounted) {
        await Provider.of<GetCountMessagesProvider>(context, listen: false)
            .loadCount();
      }
    });
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Consumer<GetMessageUserProvider>(
      builder: (context, provider, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Уведомления'),
          ),
          body: provider.isLoading
              ? const Center(child: Text('Загрузка уведомлений...'))
              : provider.messages.isEmpty
                  ? Center(
                      child: Text(
                        'Уведомлений пока нет',
                        style: TextStyle(
                          color: colorScheme.onSurfaceVariant,
                          fontSize: 16,
                        ),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: provider.messages.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final message = provider.messages[index];
                        return Dismissible(
                          key: ValueKey<String>(message.id),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 24),
                            decoration: BoxDecoration(
                              color: colorScheme.error,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Icon(
                                  Icons.delete_outline_rounded,
                                  color: colorScheme.onError,
                                  size: 26,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Удалить',
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    color: colorScheme.onError,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          confirmDismiss: (_) async {
                            final token = Provider.of<AuthProvider>(
                              context,
                              listen: false,
                            ).token;
                            final messenger = ScaffoldMessenger.maybeOf(context);
                            final err =
                                await provider.deleteMessage(message.id);
                            if (!context.mounted) return false;
                            if (err != null) {
                              HapticFeedback.mediumImpact();
                              messenger?.showSnackBar(
                                SnackBar(
                                  content: Text(err),
                                  behavior: SnackBarBehavior.floating,
                                  margin: const EdgeInsets.fromLTRB(
                                    16,
                                    0,
                                    16,
                                    88,
                                  ),
                                ),
                              );
                              return false;
                            }
                            HapticFeedback.lightImpact();
                            final countProvider =
                                Provider.of<GetCountMessagesProvider>(
                              context,
                              listen: false,
                            );
                            await countProvider.loadCount();
                            return true;
                          },
                          child: Card(
                            clipBehavior: Clip.antiAlias,
                            elevation: 0,
                            color: colorScheme.surfaceContainerHighest
                                .withValues(alpha: 0.55),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
                              leading: Icon(
                                Icons.notifications_active_outlined,
                                color: colorScheme.primary,
                              ),
                              title: Text(
                                message.content,
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  color: colorScheme.onSurface,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              subtitle: Padding(
                                padding: const EdgeInsets.only(top: 6),
                                child: Text(
                                  _formatTime(message.createdAt),
                                  style: TextStyle(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
        );
      },
    );
  }
}
