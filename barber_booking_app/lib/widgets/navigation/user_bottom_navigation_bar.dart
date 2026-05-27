import 'package:barber_booking_app/widgets/navigation/chat_badge_icon.dart';
import 'package:flutter/material.dart';

class UserBottomNavigationBar extends StatelessWidget {
  const UserBottomNavigationBar({
    super.key,
    required this.selectedIndex,
    required this.onTap,
  });

  final int selectedIndex;
  final ValueChanged<int> onTap;

  static void navigateByIndex(BuildContext context, int index) {
    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/home');
        break;
      case 1:
        Navigator.pushReplacementNamed(context, '/search_screen');
        break;
      case 2:
        Navigator.pushReplacementNamed(context, '/appointments_screen');
        break;
      case 3:
        Navigator.pushReplacementNamed(context, '/chat_conversations');
        break;
      case 4:
        Navigator.pushReplacementNamed(context, '/favorites_screen');
        break;
      case 5:
        Navigator.pushReplacementNamed(context, '/profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: selectedIndex,
      onTap: onTap,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Главная'),
        BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Поиск'),
        BottomNavigationBarItem(
          icon: Icon(Icons.calendar_today),
          label: 'Записи',
        ),
        BottomNavigationBarItem(
          icon: ChatBadgeIcon(icon: Icons.chat_bubble_outline),
          activeIcon: ChatBadgeIcon(
            icon: Icons.chat_bubble_outline,
            selectedIcon: Icons.chat_bubble,
            useSelected: true,
          ),
          label: 'Сообщения',
        ),
        BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Избранное'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Профиль'),
      ],
    );
  }
}

