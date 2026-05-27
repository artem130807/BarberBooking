import 'package:barber_booking_app/providers/chat_providers/chat_conversations_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ChatBadgeIcon extends StatelessWidget {
  const ChatBadgeIcon({
    super.key,
    this.icon = Icons.chat_bubble_outline,
    this.selectedIcon = Icons.chat_bubble,
    this.color,
    this.useSelected = false,
  });

  final IconData icon;
  final IconData selectedIcon;
  final Color? color;
  final bool useSelected;

  @override
  Widget build(BuildContext context) {
    return Consumer<ChatConversationsProvider>(
      builder: (context, provider, _) {
        final count = provider.totalUnread;
        final baseIcon = Icon(
          useSelected ? selectedIcon : icon,
          color: color,
        );
        if (count <= 0) return baseIcon;
        return Badge(
          label: Text(count > 99 ? '99+' : '$count'),
          child: baseIcon,
        );
      },
    );
  }
}

