import 'package:barber_booking_app/models/chat_models/chat_conversation_summary.dart';
import 'package:barber_booking_app/providers/chat_providers/chat_conversations_provider.dart';
import 'package:barber_booking_app/screens/chat/chat_dialog_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ChatNavigation {
  ChatNavigation._();

  static Future<void> openOrCreateConversationWithParticipant(
    BuildContext context, {
    required String participantId,
    required String participantName,
  }) async {
    final provider = context.read<ChatConversationsProvider>();

    final conversation = await provider.createOrFindConversation(
      participantId: participantId,
      participantName: participantName,
    );

    if (!context.mounted) return;

    if (conversation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Не удалось открыть диалог. Попробуйте позже.'),
        ),
      );
      return;
    }

    await _openConversation(context, conversation);

    if (!context.mounted) return;
    await provider.refresh();
  }

  static Future<void> openConversationBySummary(
    BuildContext context,
    ChatConversationSummary summary,
  ) async {
    await _openConversation(context, summary);
  }

  static Future<void> _openConversation(
    BuildContext context,
    ChatConversationSummary summary,
  ) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ChatDialogScreen(
          conversationId: summary.id,
          conversationTitle: summary.userName,
        ),
      ),
    );
  }
}

