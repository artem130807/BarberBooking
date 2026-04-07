import 'package:barber_booking_app/providers/auth_providers/auth_provider.dart';
import 'package:barber_booking_app/providers/master_providers/master_session_provider.dart';
import 'package:barber_booking_app/providers/message_providers/get_count_messages_provider.dart';
import 'package:barber_booking_app/screens/master/master_appointments_list_screen.dart';
import 'package:barber_booking_app/screens/master/master_navigation.dart';
import 'package:barber_booking_app/screens/master/master_profile_tab_screen.dart';
import 'package:barber_booking_app/screens/master/master_slots_screen.dart';
import 'package:barber_booking_app/screens/master/master_today_screen.dart';
import 'package:barber_booking_app/widgets/loading_indicator.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MasterShellScreen extends StatefulWidget {
  const MasterShellScreen({super.key});

  @override
  State<MasterShellScreen> createState() => _MasterShellScreenState();
}

class _MasterShellScreenState extends State<MasterShellScreen> {
  int _index = 0;
  bool _readRouteArgs = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_readRouteArgs) return;
    _readRouteArgs = true;
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is MasterShellArgs) {
      _index = args.initialTab.clamp(0, 3);
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final token = context.read<AuthProvider>().token;
      context.read<MasterSessionProvider>().load(token);
      context.read<GetCountMessagesProvider>().loadCount(token);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MasterSessionProvider>(
      builder: (context, session, _) {
        if (session.isLoading && session.profile == null) {
          return const Scaffold(
            body: Center(
              child: LoadingIndicator(message: 'Загрузка…'),
            ),
          );
        }
        if (session.errorMessage != null && session.profile == null) {
          return Scaffold(
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 48,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      session.errorMessage ?? 'Ошибка',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    FilledButton(
                      onPressed: () {
                        final token = context.read<AuthProvider>().token;
                        session.load(token);
                      },
                      child: const Text('Повторить'),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
        final profile = session.profile;
        if (profile == null) {
          return const Scaffold(
            body: Center(child: Text('Профиль мастера недоступен')),
          );
        }
        return Scaffold(
          body: IndexedStack(
            index: _index,
            children: [
              MasterTodayScreen(profile: profile),
              const MasterAppointmentsListScreen(),
              MasterSlotsScreen(masterId: profile.Id ?? ''),
              MasterProfileTabScreen(profile: profile),
            ],
          ),
          bottomNavigationBar: MasterBottomNavigationBar(
            selectedIndex: _index,
            onDestinationSelected: (i) => setState(() => _index = i),
          ),
        );
      },
    );
  }
}
