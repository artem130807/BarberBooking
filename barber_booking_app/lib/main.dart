import 'package:barber_booking_app/models/master_models/response/get_master_response.dart';
import 'package:barber_booking_app/models/master_models/response/get_masters_response.dart';
import 'package:barber_booking_app/providers/appointment_providers/%D1%81reate_appointment_provider.dart';
import 'package:barber_booking_app/providers/appointment_providers/delete_appointment_provider.dart';
import 'package:barber_booking_app/providers/appointment_providers/get_appointment_awaiting_review_provider.dart';
import 'package:barber_booking_app/providers/appointment_providers/get_appointment_client_provider.dart';
import 'package:barber_booking_app/providers/appointment_providers/get_appointments_by_client_provider.dart';
import 'package:barber_booking_app/providers/appointment_providers/get_salon_appointments_admin_provider.dart';
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
import 'package:barber_booking_app/providers/salon_providers/get_salons_provider.dart';
import 'package:barber_booking_app/providers/salon_providers/get_salons_by_service_provider.dart';
import 'package:barber_booking_app/providers/salon_providers/get_salons_search_provider.dart';
import 'package:barber_booking_app/providers/salon_providers/get_salon_admin_stats_provider.dart';
import 'package:barber_booking_app/providers/service_providers/admin_salon_services_provider.dart';
import 'package:barber_booking_app/providers/master_providers/admin_salon_masters_provider.dart';
import 'package:barber_booking_app/providers/service_providers/get_service_search_provider.dart';
import 'package:barber_booking_app/providers/service_providers/get_services_provider.dart';
import 'package:barber_booking_app/providers/time_slot_providers/get_slots_provider.dart';
import 'package:barber_booking_app/providers/user_providers/get_user_cities_provider.dart';
import 'package:barber_booking_app/providers/user_providers/get_user_provider.dart';
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
import 'package:barber_booking_app/screens/admin/admin_shell_screen.dart';
import 'package:barber_booking_app/screens/admin/admin_appointments_period_screen.dart';
import 'package:barber_booking_app/screens/admin/admin_revenue_screen.dart';
import 'package:barber_booking_app/screens/admin/admin_salon_detail_screen.dart';
import 'package:barber_booking_app/screens/admin/admin_salon_services_screen.dart';
import 'package:barber_booking_app/screens/admin/admin_salon_masters_screen.dart';
import 'package:provider/provider.dart';
import 'package:barber_booking_app/providers/auth_providers/auth_provider.dart';
import 'package:barber_booking_app/providers/auth_providers/email_verify_provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => EmailVerifyProvider()),
        ChangeNotifierProvider(create: (_) => GetSalonsProvider()),
        ChangeNotifierProvider(create: (_) => GetSalonsSearchProvider()),
        ChangeNotifierProvider(create: (_) => GetSalonsByServiceProvider()),
        ChangeNotifierProvider(create: (_) => GetSalonProvider()),
        ChangeNotifierProvider(create: (_) => GetTheBestMastersProvider()),
        ChangeNotifierProvider(create: (_) => GetMastersProvider()),
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
        ChangeNotifierProvider(create: (_) => AdminSalonServicesProvider()),
        ChangeNotifierProvider(create: (_) => AdminSalonMastersProvider()),
      ],
      child: MaterialApp(
        title: 'BarberBooking',
        theme: AppTheme.darkTheme,
        initialRoute: '/login',
        routes: {
          '/login': (context) => const LoginScreen(),
          '/register': (context) => const RegisterScreen(),
          '/home': (context) => const HomeScreen(),
          '/admin_home': (context) => const AdminShellScreen(),
          '/admin_appointments_period': (context) =>
              const AdminAppointmentsPeriodScreen(),
          '/admin_revenue': (context) => const AdminRevenueScreen(),
          '/admin_salon_detail': (context) {
            final id =
                ModalRoute.of(context)!.settings.arguments as String;
            return AdminSalonDetailScreen(salonId: id);
          },
          '/admin_salon_services': (context) {
            final id =
                ModalRoute.of(context)!.settings.arguments as String;
            return AdminSalonServicesScreen(salonId: id);
          },
          '/admin_salon_masters': (context) {
            final id =
                ModalRoute.of(context)!.settings.arguments as String;
            return AdminSalonMastersScreen(salonId: id);
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
