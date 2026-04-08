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

  /// Переход на вкладку shell мастера (сбрасывает стек до `/master_home`).
  static void goToTab(BuildContext context, int index) {
    final i = index.clamp(0, 3);
    Navigator.of(context).pushNamedAndRemoveUntil(
      '/master_home',
      (route) => false,
      arguments: MasterShellArgs(initialTab: i),
    );
  }
}

/// Нижняя навигация мастера для экранов поверх [MasterShellScreen] (не для вкладок внутри shell).
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
        selectedIndex: selectedTabIndex.clamp(0, 3),
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
