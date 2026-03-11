import 'package:barber_booking_app/models/master_models/response/get_master_response.dart';
import 'package:barber_booking_app/models/master_models/response/get_masters_response.dart';
import 'package:barber_booking_app/providers/appointment_providers/%D1%81reate_appointment_provider.dart';
import 'package:barber_booking_app/providers/appointment_providers/get_appointments_by_client_provider.dart';
import 'package:barber_booking_app/providers/master_providers/get_master_provider.dart';
import 'package:barber_booking_app/providers/master_providers/get_the_best_masters_provider.dart';
import 'package:barber_booking_app/providers/master_providers/get_masters_provider.dart';
import 'package:barber_booking_app/providers/master_subscription_providers/create_subscription_provider.dart';
import 'package:barber_booking_app/providers/master_subscription_providers/delete_subscription_provider.dart';
import 'package:barber_booking_app/providers/master_subscription_providers/get_subscriptions_provider.dart';
import 'package:barber_booking_app/providers/review_providers/get_reviews_master_provider.dart';
import 'package:barber_booking_app/providers/review_providers/get_reviews_salon_provider.dart';
import 'package:barber_booking_app/providers/salon_providers/get_salon_provider.dart';
import 'package:barber_booking_app/providers/salon_providers/get_salons_provider.dart';
import 'package:barber_booking_app/providers/salon_providers/get_salons_by_service_provider.dart';
import 'package:barber_booking_app/providers/salon_providers/get_salons_search_provider.dart';
import 'package:barber_booking_app/providers/service_providers/get_services_provider.dart';
import 'package:barber_booking_app/providers/time_slot_providers/get_slots_provider.dart';
import 'package:barber_booking_app/screens/appointment_screens/appointments_screen.dart';
import 'package:barber_booking_app/screens/review_screens/reviews_by_master_screen.dart';
import 'package:barber_booking_app/screens/review_screens/reviews_by_salon_screen.dart';
import 'package:barber_booking_app/screens/salon_screens/salon_screen.dart';
import 'package:barber_booking_app/screens/master_screens/master_detail_screen.dart';
import 'package:barber_booking_app/screens/salon_screens/salon_masters_screen.dart';
import 'package:barber_booking_app/screens/salon_screens/salons_by_service_screen.dart';
import 'package:barber_booking_app/screens/salon_screens/salons_screen.dart';
import 'package:barber_booking_app/screens/salon_screens/search_results_screen.dart';
import 'package:barber_booking_app/screens/subscribtions_screens/favorites_screen.dart';
import 'package:flutter/material.dart';
import 'screens/auth_screens/login_screen.dart';
import 'screens/auth_screens/register_screen.dart';
import 'screens/home_screen.dart';
import 'screens/auth_screens/forgot_password_screen.dart';
import 'screens/auth_screens/email_verification_screen.dart';
import 'screens/auth_screens/verify_code_screen.dart';
import 'screens/auth_screens/veify_code_updatepassword_screen.dart';
import 'screens/auth_screens/update_password_screen.dart';
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
        ChangeNotifierProvider(create: (_) => GetAppointmentsByClientProvider()),
        ChangeNotifierProvider(create: (_) => CreateAppointmentProvider()),
        ChangeNotifierProvider(create: (_) => CreateSubscriptionProvider()),
        ChangeNotifierProvider(create: (_) => DeleteSubscriptionProvider()),
        ChangeNotifierProvider(create: (_) => GetSubscriptionsProvider())
      ],
      child: MaterialApp(
        title: 'BarberBooking',
        theme: ThemeData(        
          primarySwatch: Colors.blue,
          fontFamily: 'Roboto',
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            elevation: 0,
          ),
        ),
        initialRoute: '/login',
        routes: {
          '/login': (context) => const LoginScreen(),
          '/register': (context) => const RegisterScreen(),
          '/home': (context) => const HomeScreen(),
          '/forgot': (context) => const ForgotPasswordScreen(),
          '/email-verification': (context) => const EmailVerificationScreen(),
          '/verify-code': (context) => const VerifyCodeScreen(),
          '/verify-codeUpdatePass': (context) => const VerifyCodeUpdatePassScreen(),
          '/update-password': (context) => const UpdatePasswordScreen(),
          '/search-results': (context) => const SearchResultsScreen(query: ''),
          '/salons_screen': (context) => const SalonsScreen(),
          '/appointments_screen': (context) => const AppointmentsScreen(),
          '/favorites_screen':(context) => const FavoritesScreen(),
          '/master_reviews': (context) {
            final masterId = ModalRoute.of(context)!.settings.arguments as String;
            return ReviewsByMasterScreen(masterId: masterId);
          },
          '/salon_reviews': (context) {
            final salonId = ModalRoute.of(context)!.settings.arguments as String;
            return ReviewsBySalonScreen(salonId: salonId);
          },
          '/salons_by_service': (context) {
            final serviceName = ModalRoute.of(context)!.settings.arguments as String;
            return SalonsByServiceScreen(serviceName: serviceName);
          },
          '/salon_screen': (context) {
            final args = ModalRoute.of(context)!.settings.arguments as String;
            return SalonScreen(salonId: args);
          },
            '/master_detail': (context) {
            final masterId = ModalRoute.of(context)!.settings.arguments as String;
            return MasterDetailScreen(masterId: masterId);
          },
          '/salon_masters': (context) {
            final args = ModalRoute.of(context)!.settings.arguments as String;
            return SalonMastersScreen(salonId: args);
          },

        },
      ),
    );
  }
}