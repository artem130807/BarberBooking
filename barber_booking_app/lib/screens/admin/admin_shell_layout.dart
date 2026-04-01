import 'package:barber_booking_app/screens/admin/admin_navigation.dart';
import 'package:flutter/material.dart';

class AdminShellLayout extends StatelessWidget {
  const AdminShellLayout({
    super.key,
    required this.selectedTab,
    required this.child,
  });

  final int selectedTab;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final idx = selectedTab.clamp(0, 3);
    return Scaffold(
      body: child,
      bottomNavigationBar: AdminBottomNavigationBar(
        selectedIndex: idx,
        onDestinationSelected: (i) {
          if (i == idx) return;
          Navigator.of(context).pushNamedAndRemoveUntil(
            '/admin_home',
            (route) => false,
            arguments: AdminShellArgs(initialTab: i),
          );
        },
      ),
    );
  }
}
