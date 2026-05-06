import 'dart:async';

import 'package:barber_booking_app/providers/appointment_providers/%D1%81reate_appointment_provider.dart';
import 'package:barber_booking_app/providers/appointment_providers/delete_appointment_provider.dart';
import 'package:barber_booking_app/providers/appointment_providers/get_appointment_awaiting_review_provider.dart';
import 'package:barber_booking_app/providers/appointment_providers/get_appointment_client_provider.dart';
import 'package:barber_booking_app/providers/appointment_providers/get_appointments_by_client_provider.dart';
import 'package:barber_booking_app/providers/appointment_providers/get_salon_appointments_admin_provider.dart';
import 'package:barber_booking_app/providers/master_providers/master_session_provider.dart';
import 'package:barber_booking_app/providers/master_providers/get_master_provider.dart';
import 'package:barber_booking_app/providers/master_providers/get_the_best_masters_provider.dart';
import 'package:barber_booking_app/providers/master_providers/get_masters_provider.dart';
import 'package:barber_booking_app/providers/master_subscription_providers/create_subscription_provider.dart';
import 'package:barber_booking_app/providers/master_subscription_providers/delete_subscription_provider.dart';
import 'package:barber_booking_app/providers/master_subscription_providers/get_subscriptions_provider.dart';
import 'package:barber_booking_app/providers/message_providers/get_count_messages_provider.dart';
import 'package:barber_booking_app/providers/message_providers/get_message_user_provider.dart';
import 'package:barber_booking_app/providers/review_providers/create_review_user_provider.dart';
import 'package:barber_booking_app/providers/review_providers/delete_review_user_provider.dart';
import 'package:barber_booking_app/providers/review_providers/get_reviews_master_provider.dart';
import 'package:barber_booking_app/providers/review_providers/get_reviews_salon_provider.dart';
import 'package:barber_booking_app/providers/review_providers/get_reviews_user_provider.dart';
import 'package:barber_booking_app/providers/review_providers/get_reviews_admin_provider.dart';
import 'package:barber_booking_app/providers/review_providers/update_review_user_provider.dart';
import 'package:barber_booking_app/providers/salon_providers/get_salon_provider.dart';
import 'package:barber_booking_app/providers/salon_providers/get_salons_admin_provider.dart';
import 'package:barber_booking_app/providers/salon_providers/get_salons_provider.dart';
import 'package:barber_booking_app/providers/salon_providers/get_salons_by_service_provider.dart';
import 'package:barber_booking_app/providers/salon_providers/get_salons_search_provider.dart';
import 'package:barber_booking_app/providers/salon_providers/get_salon_admin_stats_provider.dart';
import 'package:barber_booking_app/providers/salon_providers/salon_statistic_period_provider.dart';
import 'package:barber_booking_app/providers/salon_providers/salon_statistics_filter_provider.dart';
import 'package:barber_booking_app/providers/service_providers/admin_salon_services_provider.dart';
import 'package:barber_booking_app/providers/master_providers/admin_salon_masters_provider.dart';
import 'package:barber_booking_app/providers/master_providers/admin_master_profile_provider.dart';
import 'package:barber_booking_app/providers/admin_top_masters_provider.dart';
import 'package:barber_booking_app/providers/admin_top_services_provider.dart';
import 'package:barber_booking_app/providers/service_providers/get_service_search_provider.dart';
import 'package:barber_booking_app/providers/service_providers/get_services_provider.dart';
import 'package:barber_booking_app/providers/time_slot_providers/get_slots_provider.dart';
import 'package:barber_booking_app/providers/user_providers/get_user_cities_provider.dart';
import 'package:barber_booking_app/providers/user_providers/get_user_provider.dart';
import 'package:barber_booking_app/providers/user_providers/get_user_profile_by_id_provider.dart';
import 'package:barber_booking_app/providers/user_providers/update_user_city_provider.dart';
import 'package:barber_booking_app/screens/user_interfaces/appointment_screens/appointments_screen.dart';
import 'package:barber_booking_app/screens/user_interfaces/review_screens/reviews_by_master_screen.dart';
import 'package:barber_booking_app/screens/user_interfaces/review_screens/reviews_by_salon_screen.dart';
import 'package:barber_booking_app/screens/user_interfaces/salon_screens/salon_screen.dart';
import 'package:barber_booking_app/screens/user_interfaces/master_screens/master_detail_screen.dart';
import 'package:barber_booking_app/screens/user_interfaces/salon_screens/salon_masters_screen.dart';
import 'package:barber_booking_app/screens/user_interfaces/salon_screens/salons_by_service_screen.dart';
import 'package:barber_booking_app/screens/user_interfaces/salon_screens/salons_screen.dart';
import 'package:barber_booking_app/screens/user_interfaces/salon_screens/search_results_screen.dart';
import 'package:barber_booking_app/screens/user_interfaces/service_screens/search_services_screen.dart';
import 'package:barber_booking_app/screens/user_interfaces/subscribtions_screens/favorites_screen.dart';
import 'package:barber_booking_app/screens/user_interfaces/user_screens/profile_screen.dart';
import 'package:barber_booking_app/screens/common/sessions_screen.dart';
import 'package:barber_booking_app/screens/user_interfaces/user_screens/profile_settings_screen.dart';
import 'package:barber_booking_app/screens/user_interfaces/user_screens/user_reviews_screen.dart';
import 'package:flutter/material.dart';
import 'package:barber_booking_app/theme/app_theme.dart';
import 'package:barber_booking_app/screens/user_interfaces/auth_screens/login_screen.dart';
import 'package:barber_booking_app/screens/user_interfaces/auth_screens/register_screen.dart';
import 'package:barber_booking_app/screens/home_screen.dart';
import 'package:barber_booking_app/screens/user_interfaces/auth_screens/forgot_password_screen.dart';
import 'package:barber_booking_app/screens/user_interfaces/auth_screens/email_verification_screen.dart';
import 'package:barber_booking_app/screens/user_interfaces/auth_screens/verify_code_screen.dart';
import 'package:barber_booking_app/screens/user_interfaces/auth_screens/veify_code_updatepassword_screen.dart';
import 'package:barber_booking_app/screens/user_interfaces/auth_screens/update_password_screen.dart';
import 'package:barber_booking_app/screens/user_interfaces/message_screens/messages_screen.dart';
import 'package:barber_booking_app/screens/user_interfaces/appointment_screens/appointment_detail_screen.dart';
import 'package:barber_booking_app/screens/admin/admin_navigation.dart';
import 'package:barber_booking_app/screens/admin/admin_shell_layout.dart';
import 'package:barber_booking_app/screens/master/master_notifications_screen.dart';
import 'package:barber_booking_app/screens/master/master_shell_screen.dart';
import 'package:barber_booking_app/screens/admin/admin_shell_screen.dart';
import 'package:barber_booking_app/screens/admin/admin_appointments_period_screen.dart';
import 'package:barber_booking_app/screens/admin/admin_reviews_screen.dart';
import 'package:barber_booking_app/screens/admin/admin_revenue_screen.dart';
import 'package:barber_booking_app/screens/admin/admin_create_salon_screen.dart';
import 'package:barber_booking_app/screens/admin/admin_salon_detail_screen.dart';
import 'package:barber_booking_app/screens/admin/admin_salon_services_screen.dart';
import 'package:barber_booking_app/screens/admin/admin_salon_masters_screen.dart';
import 'package:barber_booking_app/screens/admin/admin_salon_statistics_screen.dart';
import 'package:barber_booking_app/screens/admin/admin_top_masters_screen.dart';
import 'package:barber_booking_app/screens/admin/admin_top_services_screen.dart';
import 'package:barber_booking_app/screens/admin/admin_client_profile_screen.dart';
import 'package:barber_booking_app/screens/admin/admin_master_profile_screen.dart';
import 'package:provider/provider.dart';
import 'package:barber_booking_app/providers/auth_providers/auth_provider.dart';
import 'package:barber_booking_app/providers/auth_providers/email_verify_provider.dart';
import 'package:barber_booking_app/providers/notification_providers/notification_toast_controller.dart';
import 'package:barber_booking_app/services/push/fcm_background_handler.dart';
import 'package:barber_booking_app/services/push/notification_service.dart';
import 'package:barber_booking_app/services/realtime/signalr_notification_service.dart';
import 'package:barber_booking_app/widgets/notifications/auth_signal_r_bootstrap.dart';
import 'package:barber_booking_app/widgets/notifications/notification_toast_overlay.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:barber_booking_app/firebase_options.dart';
import 'package:barber_booking_app/navigation/role_routes.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _bootstrapFirebaseCore();
  final authProvider = AuthProvider();
  await authProvider.restoreFromStorage();
  runApp(MyApp(authProvider: authProvider));
  _schedulePostFrameBootstrap();
}

/// Минимальная синхронная часть Firebase: не блокировать первый кадр тяжёлым FCM/HTTP.
Future<void> _bootstrapFirebaseCore() async {
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    ).timeout(const Duration(seconds: 25));
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  } catch (e, st) {
    debugPrint('Firebase core: $e\n$st');
  }
}

void _schedulePostFrameBootstrap() {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    unawaited(_bootstrapNotificationsAndPush());
  });
}

Future<void> _bootstrapNotificationsAndPush() async {
  try {
    await NotificationService.instance
        .initialize()
        .timeout(const Duration(seconds: 35));
  } catch (e, st) {
    debugPrint('NotificationService init: $e\n$st');
  }
  try {
    await NotificationService.instance
        .syncFcmRegistrationWithBackend()
        .timeout(const Duration(seconds: 18));
  } catch (e, st) {
    debugPrint('FCM backend sync: $e\n$st');
  }
}

class MyApp extends StatelessWidget {
  final AuthProvider authProvider;

  const MyApp({super.key, required this.authProvider});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: authProvider),
        ChangeNotifierProvider(create: (_) => NotificationToastController()),
        Provider<SignalRNotificationService>(
          create: (context) => SignalRNotificationService(
            context.read<NotificationToastController>(),
          ),
          dispose: (_, s) => s.disposeSync(),
        ),
        ChangeNotifierProvider(create: (_) => EmailVerifyProvider()),
        ChangeNotifierProvider(create: (_) => GetSalonsProvider()),
        ChangeNotifierProvider(create: (_) => GetSalonsAdminProvider()),
        ChangeNotifierProvider(create: (_) => GetSalonsSearchProvider()),
        ChangeNotifierProvider(create: (_) => GetSalonsByServiceProvider()),
        ChangeNotifierProvider(create: (_) => GetSalonProvider()),
        ChangeNotifierProvider(create: (_) => GetTheBestMastersProvider()),
        ChangeNotifierProvider(create: (_) => GetMastersProvider()),
        ChangeNotifierProvider(create: (_) => MasterSessionProvider()),
        ChangeNotifierProvider(create: (_) => GetMasterProvider()),
        ChangeNotifierProvider(create: (_) => GetReviewsMasterProvider()),
        ChangeNotifierProvider(create: (_) => GetReviewsSalonProvider()),
        ChangeNotifierProvider(create: (_) => GetServicesProvider()),
        ChangeNotifierProvider(create: (_) => GetSlotsProvider()),
        ChangeNotifierProvider(
            create: (_) => GetAppointmentAwaitingReviewProvider()),
        ChangeNotifierProvider(
            create: (_) => GetAppointmentsByClientProvider()),
        ChangeNotifierProvider(create: (_) => CreateAppointmentProvider()),
        ChangeNotifierProvider(create: (_) => CreateSubscriptionProvider()),
        ChangeNotifierProvider(create: (_) => DeleteSubscriptionProvider()),
        ChangeNotifierProvider(create: (_) => GetSubscriptionsProvider()),
        ChangeNotifierProvider(create: (_) => GetServiceSearchProvider()),
        ChangeNotifierProvider(create: (_) => GetUserProvider()),
        ChangeNotifierProvider(create: (_) => GetUserProfileByIdProvider()),
        ChangeNotifierProvider(create: (_) => AdminMasterProfileProvider()),
        ChangeNotifierProvider(create: (_) => GetUserCitiesProvider()),
        ChangeNotifierProvider(create: (_) => UpdateUserCityProvider()),
        ChangeNotifierProvider(create: (_) => GetReviewsUserProvider()),
        ChangeNotifierProvider(create: (_) => DeleteReviewUserProvider()),
        ChangeNotifierProvider(create: (_) => UpdateReviewUserProvider()),
        ChangeNotifierProvider(create: (_) => CreateReviewUserProvider()),
        ChangeNotifierProvider(create: (_) => GetCountMessagesProvider()),
        ChangeNotifierProvider(create: (_) => GetMessageUserProvider()),
        ChangeNotifierProvider(create: (_) => GetAppointmentClientProvider()),
        ChangeNotifierProvider(create: (_) => DeleteAppointmentProvider()),
        ChangeNotifierProvider(create: (_) => GetSalonAppointmentsAdminProvider()),
        ChangeNotifierProvider(create: (_) => GetReviewsAdminProvider()),
        ChangeNotifierProvider(create: (_) => GetSalonAdminStatsProvider()),
        ChangeNotifierProvider(create: (_) => SalonStatisticPeriodProvider()),
        ChangeNotifierProvider(create: (_) => SalonStatisticsFilterProvider()),
        ChangeNotifierProvider(create: (_) => AdminSalonServicesProvider()),
        ChangeNotifierProvider(create: (_) => AdminSalonMastersProvider()),
        ChangeNotifierProvider(create: (_) => AdminTopMastersProvider()),
        ChangeNotifierProvider(create: (_) => AdminTopServicesProvider()),
      ],
      child: MaterialApp(
        title: 'BarberBooking',
        theme: AppTheme.darkTheme,
        home: const SessionStartGate(),
        builder: (context, child) {
          final bg = Theme.of(context).scaffoldBackgroundColor;
          final content = child ?? const _NavigatorMissingFallback();
          return Stack(
            fit: StackFit.expand,
            clipBehavior: Clip.hardEdge,
            children: [
              Positioned.fill(
                child: IgnorePointer(
                  child: DecoratedBox(
                    decoration: BoxDecoration(color: bg),
                    child: const SizedBox.expand(),
                  ),
                ),
              ),
              Positioned.fill(
                child: AuthSignalRBootstrap(child: content),
              ),
              const NotificationToastOverlay(),
            ],
          );
        },
        onUnknownRoute: (settings) {
          debugPrint('Unknown route: ${settings.name}');
          return MaterialPageRoute<void>(
            builder: (context) => const LoginScreen(),
            settings: settings,
          );
        },
        routes: {
          '/login': (context) => const LoginScreen(),
          '/register': (context) => const RegisterScreen(),
          '/home': (context) => const HomeScreen(),
          '/admin_home': (context) => const AdminShellScreen(),
          '/master_home': (context) => const MasterShellScreen(),
          '/master_notifications': (context) =>
              const MasterNotificationsScreen(),
          '/admin_appointments_period': (context) => AdminShellLayout(
                selectedTab: AdminNav.dashboard,
                child: const AdminAppointmentsPeriodScreen(),
              ),
          '/admin_revenue': (context) => AdminShellLayout(
                selectedTab: AdminNav.dashboard,
                child: const AdminRevenueScreen(),
              ),
          '/admin_top_masters': (context) => AdminShellLayout(
                selectedTab: AdminNav.dashboard,
                child: const AdminTopMastersScreen(),
              ),
          '/admin_top_services': (context) => AdminShellLayout(
                selectedTab: AdminNav.dashboard,
                child: const AdminTopServicesScreen(),
              ),
          '/admin_create_salon': (context) => AdminShellLayout(
                selectedTab: AdminNav.salons,
                child: const AdminCreateSalonScreen(),
              ),
          '/admin_salon_detail': (context) {
            final id =
                ModalRoute.of(context)!.settings.arguments as String;
            return AdminShellLayout(
              selectedTab: AdminNav.salons,
              child: AdminSalonDetailScreen(salonId: id),
            );
          },
          '/admin_salon_services': (context) {
            final id =
                ModalRoute.of(context)!.settings.arguments as String;
            return AdminShellLayout(
              selectedTab: AdminNav.salons,
              child: AdminSalonServicesScreen(salonId: id),
            );
          },
          '/admin_salon_masters': (context) {
            final id =
                ModalRoute.of(context)!.settings.arguments as String;
            return AdminShellLayout(
              selectedTab: AdminNav.salons,
              child: AdminSalonMastersScreen(salonId: id),
            );
          },
          '/admin_salon_statistics': (context) {
            final id =
                ModalRoute.of(context)!.settings.arguments as String;
            return AdminShellLayout(
              selectedTab: AdminNav.salons,
              child: AdminSalonStatisticsScreen(salonId: id),
            );
          },
          '/admin_salon_appointments': (context) {
            final id =
                ModalRoute.of(context)!.settings.arguments as String;
            return AdminShellLayout(
              selectedTab: AdminNav.salons,
              child: AdminAppointmentsPeriodScreen(initialSalonId: id),
            );
          },
          '/admin_salon_reviews': (context) {
            final id =
                ModalRoute.of(context)!.settings.arguments as String;
            return AdminShellLayout(
              selectedTab: AdminNav.salons,
              child: AdminReviewsScreen(initialSalonId: id),
            );
          },
          '/admin_client_profile': (context) {
            final args = ModalRoute.of(context)!.settings.arguments;
            if (args is AdminClientProfileArgs) {
              return AdminShellLayout(
                selectedTab: AdminNav.dashboard,
                child: AdminClientProfileScreen(
                  userId: args.userId,
                  previewName: args.previewName,
                ),
              );
            }
            return AdminShellLayout(
              selectedTab: AdminNav.dashboard,
              child: const Scaffold(
                body: Center(child: Text('Некорректные аргументы маршрута')),
              ),
            );
          },
          '/admin_master_profile': (context) {
            final args = ModalRoute.of(context)!.settings.arguments;
            if (args is AdminMasterProfileArgs) {
              return AdminShellLayout(
                selectedTab: AdminNav.dashboard,
                child: AdminMasterProfileScreen(
                  masterId: args.masterId,
                  previewName: args.previewName,
                ),
              );
            }
            return AdminShellLayout(
              selectedTab: AdminNav.dashboard,
              child: const Scaffold(
                body: Center(child: Text('Некорректные аргументы маршрута')),
              ),
            );
          },
          '/forgot': (context) => const ForgotPasswordScreen(),
          '/email-verification': (context) => const EmailVerificationScreen(),
          '/verify-code': (context) => const VerifyCodeScreen(),
          '/verify-codeUpdatePass': (context) =>
              const VerifyCodeUpdatePassScreen(),
          '/update-password': (context) => const UpdatePasswordScreen(),
          '/messages': (context) => const MessagesScreen(),
          '/search-results': (context) => const SearchResultsScreen(query: ''),
          '/salons_screen': (context) => const SalonsScreen(),
          '/appointments_screen': (context) => const AppointmentsScreen(),
          '/favorites_screen': (context) => const FavoritesScreen(),
          '/search_screen': (context) => const SearchServicesScreen(),
          '/profile': (context) => const ProfileScreen(),
          '/profile_settings': (context) => const ProfileSettingsScreen(),
          '/sessions': (context) {
            final args = ModalRoute.of(context)!.settings.arguments;
            final uid =
                args is SessionsRouteArgs ? args.adminUserId : null;
            return SessionsScreen(adminUserId: uid);
          },
          '/user_reviews': (context) => const UserReviewsScreen(),
          '/master_reviews': (context) {
            final masterId =
                ModalRoute.of(context)!.settings.arguments as String;
            return ReviewsByMasterScreen(masterId: masterId);
          },
          '/salon_reviews': (context) {
            final salonId =
                ModalRoute.of(context)!.settings.arguments as String;
            return ReviewsBySalonScreen(salonId: salonId);
          },
          '/salons_by_service': (context) {
            final serviceName =
                ModalRoute.of(context)!.settings.arguments as String;
            return SalonsByServiceScreen(serviceName: serviceName);
          },
          '/salon_screen': (context) {
            final args = ModalRoute.of(context)!.settings.arguments as String;
            return SalonScreen(salonId: args);
          },
          '/master_detail': (context) {
            final masterId =
                ModalRoute.of(context)!.settings.arguments as String;
            return MasterDetailScreen(masterId: masterId);
          },
          '/salon_masters': (context) {
            final args = ModalRoute.of(context)!.settings.arguments as String;
            return SalonMastersScreen(salonId: args);
          },
          '/appointment_detail': (context) {
            final appointmentId = ModalRoute.of(context)!.settings.arguments as String;
            return AppointmentDetailScreen(appointmentId: appointmentId);
          },
        },
      ),
    );
  }
}

/// Если у [MaterialApp.builder] временно нет `child`, без этого остаётся только фон — на тёмной теме это выглядит как «чёрный экран».
class _NavigatorMissingFallback extends StatelessWidget {
  const _NavigatorMissingFallback();

  @override
  Widget build(BuildContext context) {
    final bg = Theme.of(context).scaffoldBackgroundColor;
    return Material(
      color: bg,
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}

class SessionStartGate extends StatefulWidget {
  const SessionStartGate({super.key});

  @override
  State<SessionStartGate> createState() => _SessionStartGateState();
}

class _SessionStartGateState extends State<SessionStartGate> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final auth = context.read<AuthProvider>();
      final next = auth.isAuthenticated
          ? RoleRoutes.homeRouteForRole(auth.roleInterface)
          : '/login';
      final nav = Navigator.of(context);
      try {
        nav.pushReplacementNamed(next);
      } catch (e, st) {
        debugPrint('SessionStartGate navigation: $e\n$st');
        if (!mounted) return;
        nav.pushReplacementNamed('/login');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
