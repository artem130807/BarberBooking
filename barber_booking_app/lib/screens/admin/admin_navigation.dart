import 'package:flutter/material.dart';

class AdminShellArgs {
  const AdminShellArgs({this.initialTab = 0});

  final int initialTab;
}

abstract final class AdminNav {
  static const int dashboard = 0;
  static const int salons = 1;
  static const int reviews = 2;
  static const int profile = 3;
}

class AdminBottomNavigationBar extends StatelessWidget {
  const AdminBottomNavigationBar({
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
          icon: Icon(Icons.dashboard_outlined),
          selectedIcon: Icon(Icons.dashboard),
          label: 'Дашборд',
        ),
        NavigationDestination(
          icon: Icon(Icons.store_mall_directory_outlined),
          selectedIcon: Icon(Icons.store_mall_directory),
          label: 'Салоны',
        ),
        NavigationDestination(
          icon: Icon(Icons.reviews_outlined),
          selectedIcon: Icon(Icons.reviews),
          label: 'Отзывы',
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
