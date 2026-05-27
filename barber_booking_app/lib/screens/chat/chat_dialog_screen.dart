import 'dart:async';

import 'package:barber_booking_app/models/chat_models/chat_message_item.dart';
import 'package:barber_booking_app/providers/auth_providers/auth_provider.dart';
import 'package:barber_booking_app/providers/chat_providers/chat_conversations_provider.dart';
import 'package:barber_booking_app/services/chat_services/chat_message_service.dart';
import 'package:barber_booking_app/services/realtime/signalr_chat_service.dart';
import 'package:barber_booking_app/utils/jwt_claims.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class ChatDialogScreen extends StatefulWidget {
  const ChatDialogScreen({
    super.key,
    required this.conversationId,
    required this.conversationTitle,
  });

  final String conversationId;
  final String conversationTitle;

  @override
  State<ChatDialogScreen> createState() => _ChatDialogScreenState();
}

class _ChatDialogScreenState extends State<ChatDialogScreen> {
  final ChatMessageService _messageService = ChatMessageService();
  final SignalRChatService _chatService = SignalRChatService();
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<ChatMessageItem> _messages = const [];
  bool _loading = true;
  bool _sending = false;
  String? _currentUserId;
  Timer? _pollTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final auth = context.read<AuthProvider>();
      _currentUserId =
          JwtClaims.userIdFromToken(auth.token)?.trim().toLowerCase();
      await _loadMessages();
      await _connectRealtime();
      _pollTimer = Timer.periodic(const Duration(seconds: 15), (_) {
        _loadMessages(silent: true);
      });
    });
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _chatService.disconnect();
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _connectRealtime() async {
    final token = context.read<AuthProvider>().token;
    if (token == null || token.isEmpty) return;

    try {
      await _chatService.connect(token);
      await _chatService.joinConversation(
        widget.conversationId,
        onMessageEvent: () async {
          await _loadMessages(silent: true);
        },
      );
    } catch (_) {}
  }

  Future<void> _loadMessages({bool silent = false}) async {
    if (!silent) {
      setState(() => _loading = true);
    }

    final messages = await _messageService.getMessages(widget.conversationId);

    if (!mounted) return;

    setState(() {
      _messages = messages;
      _loading = false;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _scrollToBottom();
    });

    await context.read<ChatConversationsProvider>().refresh();
  }

  void _scrollToBottom() {
    if (!_scrollController.hasClients) return;
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
    );
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _sending) return;

    setState(() => _sending = true);
    final ok = await _messageService.sendMessage(widget.conversationId, text);

    if (!mounted) return;

    setState(() => _sending = false);

    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Не удалось отправить сообщение')),
      );
      return;
    }

    _controller.clear();
    await _loadMessages(silent: true);
  }

  bool _isMine(ChatMessageItem message) {
    final me = _currentUserId;
    if (me == null || me.isEmpty) return false;
    final senderId = message.senderId.trim().toLowerCase();
    if (senderId.isEmpty) return false;
    return senderId == me;
  }

  String _formatTime(DateTime dateTime) {
    return DateFormat('HH:mm').format(dateTime.toLocal());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.conversationTitle),
      ),
      body: Column(
        children: [
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _messages.isEmpty
                    ? const Center(child: Text('Напишите первое сообщение'))
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        itemCount: _messages.length,
                        itemBuilder: (context, index) {
                          final item = _messages[index];
                          final mine = _isMine(item);
                          final bubbleColor = mine
                              ? Theme.of(context).colorScheme.primaryContainer
                              : Theme.of(context)
                                  .colorScheme
                                  .surfaceContainerHighest;
                          final textColor = mine
                              ? Theme.of(context)
                                  .colorScheme
                                  .onPrimaryContainer
                              : Theme.of(context).colorScheme.onSurface;

                          return Align(
                            alignment: mine
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                            child: Container(
                              margin: const EdgeInsets.symmetric(vertical: 4),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              constraints: BoxConstraints(
                                maxWidth:
                                    MediaQuery.of(context).size.width * 0.78,
                              ),
                              decoration: BoxDecoration(
                                color: bubbleColor,
                                borderRadius: BorderRadius.only(
                                  topLeft: const Radius.circular(14),
                                  topRight: const Radius.circular(14),
                                  bottomLeft: Radius.circular(mine ? 14 : 4),
                                  bottomRight: Radius.circular(mine ? 4 : 14),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: mine
                                    ? CrossAxisAlignment.end
                                    : CrossAxisAlignment.start,
                                children: [
                                  if (!mine && item.senderName.isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 2),
                                      child: Text(
                                        item.senderName,
                                        style: Theme.of(context)
                                            .textTheme
                                            .labelSmall
                                            ?.copyWith(
                                              fontWeight: FontWeight.w700,
                                            ),
                                      ),
                                    ),
                                  Text(
                                    item.content,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(color: textColor),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _formatTime(item.sendTime),
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelSmall
                                        ?.copyWith(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurfaceVariant,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      textCapitalization: TextCapitalization.sentences,
                      minLines: 1,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        hintText: 'Сообщение',
                        border: OutlineInputBorder(),
                      ),
                      onSubmitted: (_) => _send(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    onPressed: _sending ? null : _send,
                    icon: _sending
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.send_rounded),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
