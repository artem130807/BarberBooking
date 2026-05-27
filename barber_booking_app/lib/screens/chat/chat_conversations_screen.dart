import 'package:barber_booking_app/navigation/chat_navigation.dart';
import 'package:barber_booking_app/providers/chat_providers/chat_conversations_provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class ChatConversationsScreen extends StatefulWidget {
  const ChatConversationsScreen({
    super.key,
    this.title = 'Сообщения',
    this.showAppBar = true,
  });

  final String title;
  final bool showAppBar;

  @override
  State<ChatConversationsScreen> createState() => _ChatConversationsScreenState();
}

class _ChatConversationsScreenState extends State<ChatConversationsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChatConversationsProvider>().refresh();
    });
  }

  String _formatLastTime(DateTime? dateTime) {
    if (dateTime == null) return '';
    final now = DateTime.now();
    final local = dateTime.toLocal();

    if (now.year == local.year &&
        now.month == local.month &&
        now.day == local.day) {
      return DateFormat('HH:mm').format(local);
    }
    return DateFormat('dd.MM').format(local);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ChatConversationsProvider>(
      builder: (context, provider, _) {
        final body = provider.isLoading && provider.conversations.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: provider.refresh,
                child: provider.conversations.isEmpty
                    ? ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: const [
                          SizedBox(height: 180),
                          Center(
                            child: Text('Диалогов пока нет'),
                          ),
                        ],
                      )
                    : ListView.separated(
                        itemCount: provider.conversations.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final item = provider.conversations[index];
                          final subtitle = item.lastMessageContent?.trim().isNotEmpty ==
                                  true
                              ? item.lastMessageContent!.trim()
                              : 'Нет сообщений';

                          return ListTile(
                            onTap: () async {
                              await ChatNavigation.openConversationBySummary(
                                context,
                                item,
                              );
                              if (!context.mounted) return;
                              await context
                                  .read<ChatConversationsProvider>()
                                  .refresh();
                            },
                            leading: CircleAvatar(
                              child: Text(
                                item.userName.isNotEmpty
                                    ? item.userName.characters.first.toUpperCase()
                                    : '?',
                              ),
                            ),
                            title: Text(
                              item.userName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            subtitle: Text(
                              subtitle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  _formatLastTime(item.lastMessageAt),
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelSmall
                                      ?.copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurfaceVariant,
                                      ),
                                ),
                                const SizedBox(height: 6),
                                if (item.unreadCount > 0)
                                  Container(
                                    constraints: const BoxConstraints(
                                      minWidth: 20,
                                      minHeight: 20,
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      item.unreadCount > 99
                                          ? '99+'
                                          : '${item.unreadCount}',
                                      textAlign: TextAlign.center,
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelSmall
                                          ?.copyWith(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onPrimary,
                                            fontWeight: FontWeight.w700,
                                          ),
                                    ),
                                  ),
                              ],
                            ),
                          );
                        },
                      ),
              );

        if (!widget.showAppBar) {
          return body;
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(widget.title),
          ),
          body: body,
        );
      },
    );
  }
}

