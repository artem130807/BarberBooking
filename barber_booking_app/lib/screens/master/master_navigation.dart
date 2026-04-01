import 'package:flutter/material.dart';

class MasterShellArgs {
  const MasterShellArgs({this.initialTab = 0});

  final int initialTab;
}

abstract final class MasterNav {
  static const int today = 0;
  static const int appointments = 1;
  static const int slots = 2;
  static const int profile = 3;
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
      selectedIndex: selectedIndex.clamp(0, 3),
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
          icon: Icon(Icons.person_outline),
          selectedIcon: Icon(Icons.person),
          label: 'Профиль',
        ),
      ],
    );
  }
}
