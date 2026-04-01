import 'package:barber_booking_app/screens/admin/admin_dashboard_placeholder_screen.dart';
import 'package:barber_booking_app/screens/admin/admin_navigation.dart';
import 'package:barber_booking_app/screens/admin/admin_profile_screen.dart';
import 'package:barber_booking_app/screens/admin/admin_reviews_screen.dart';
import 'package:barber_booking_app/screens/admin/admin_salons_tab_screen.dart';
import 'package:flutter/material.dart';

class AdminShellScreen extends StatefulWidget {
  const AdminShellScreen({super.key});

  @override
  State<AdminShellScreen> createState() => _AdminShellScreenState();
}

class _AdminShellScreenState extends State<AdminShellScreen> {
  int _index = 0;
  bool _readRouteArgs = false;

  static const List<Widget> _pages = [
    AdminDashboardPlaceholderScreen(),
    AdminSalonsTabScreen(),
    AdminReviewsScreen(),
    AdminProfileScreen(),
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_readRouteArgs) return;
    _readRouteArgs = true;
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is AdminShellArgs) {
      _index = args.initialTab.clamp(0, 3);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: _pages,
      ),
      bottomNavigationBar: AdminBottomNavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
      ),
    );
  }
}
