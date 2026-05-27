import 'package:barber_booking_app/screens/chat/chat_conversations_screen.dart';
import 'package:barber_booking_app/widgets/navigation/user_bottom_navigation_bar.dart';
import 'package:flutter/material.dart';

class UserChatTabScreen extends StatelessWidget {
  const UserChatTabScreen({super.key});

  static const int _navIndex = 3;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Сообщения'),
      ),
      body: const ChatConversationsScreen(showAppBar: false),
      bottomNavigationBar: UserBottomNavigationBar(
        selectedIndex: _navIndex,
        onTap: (index) {
          if (index == _navIndex) return;
          UserBottomNavigationBar.navigateByIndex(context, index);
        },
      ),
    );
  }
}
