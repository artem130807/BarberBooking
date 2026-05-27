import 'package:barber_booking_app/widgets/navigation/chat_badge_icon.dart';
import 'package:flutter/material.dart';

class MasterShellArgs {
  const MasterShellArgs({this.initialTab = 0});

  final int initialTab;
}

abstract final class MasterNav {
  static const int today = 0;
  static const int appointments = 1;
  static const int slots = 2;
  static const int messages = 3;
  static const int profile = 4;

  static void goToTab(BuildContext context, int index) {
    final i = index.clamp(0, 4);
    Navigator.of(context).pushNamedAndRemoveUntil(
      '/master_home',
      (route) => false,
      arguments: MasterShellArgs(initialTab: i),
    );
  }
}

class MasterScreenScaffold extends StatelessWidget {
  const MasterScreenScaffold({
    super.key,
    required this.selectedTabIndex,
    required this.body,
    this.appBar,
    this.floatingActionButton,
    this.backgroundColor,
    this.resizeToAvoidBottomInset = true,
  });

  final int selectedTabIndex;
  final Widget body;
  final PreferredSizeWidget? appBar;
  final Widget? floatingActionButton;
  final Color? backgroundColor;
  final bool resizeToAvoidBottomInset;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: appBar,
      body: body,
      floatingActionButton: floatingActionButton,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      bottomNavigationBar: MasterBottomNavigationBar(
        selectedIndex: selectedTabIndex.clamp(0, 4),
        onDestinationSelected: (i) => MasterNav.goToTab(context, i),
      ),
    );
  }
}

class MasterBottomNavigationBar extends StatelessWidget {
  const MasterBottomNavigationBar({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: selectedIndex.clamp(0, 4),
      onDestinationSelected: onDestinationSelected,
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.today_outlined),
          selectedIcon: Icon(Icons.today),
          label: 'Сегодня',
        ),
        NavigationDestination(
          icon: Icon(Icons.event_note_outlined),
          selectedIcon: Icon(Icons.event_note),
          label: 'Записи',
        ),
        NavigationDestination(
          icon: Icon(Icons.schedule_outlined),
          selectedIcon: Icon(Icons.schedule),
          label: 'Слоты',
        ),
        NavigationDestination(
          icon: ChatBadgeIcon(icon: Icons.chat_bubble_outline),
          selectedIcon: ChatBadgeIcon(
            icon: Icons.chat_bubble_outline,
            selectedIcon: Icons.chat_bubble,
            useSelected: true,
          ),
          label: 'Сообщения',
        ),
        NavigationDestination(
          icon: Icon(Icons.person_outline),
          selectedIcon: Icon(Icons.person),
          label: 'Профиль',
        ),
      ],
    );
  }
}

