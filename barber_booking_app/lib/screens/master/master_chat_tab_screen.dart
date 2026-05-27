import 'package:barber_booking_app/screens/chat/chat_conversations_screen.dart';
import 'package:flutter/material.dart';

class MasterChatTabScreen extends StatelessWidget {
  const MasterChatTabScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Сообщения'),
        automaticallyImplyLeading: false,
      ),
      body: const ChatConversationsScreen(showAppBar: false),
    );
  }
}
