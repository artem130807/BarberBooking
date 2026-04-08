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
    final bg = Theme.of(context).scaffoldBackgroundColor;
    final i = _index.clamp(0, _pages.length - 1);
    return Scaffold(
      backgroundColor: bg,
      body: ColoredBox(
        color: bg,
        child: _pages[i],
      ),
      bottomNavigationBar: AdminBottomNavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
      ),
    );
  }
}
