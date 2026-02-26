import 'package:barber_booking_app/providers/salonProviders/get_salons_provider.dart';
import 'package:barber_booking_app/providers/salonProviders/get_salons_search_provider.dart';
import 'package:barber_booking_app/screens/salon_screens/salons_screen.dart';
import 'package:barber_booking_app/screens/salon_screens/search_results_screen.dart';
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
import 'package:barber_booking_app/providers/authProviders/auth_provider.dart';
import 'package:barber_booking_app/providers/authProviders/email_verify_provider.dart';
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

   @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => 
        AuthProvider()),
        ChangeNotifierProvider(create: (_) => 
        EmailVerifyProvider()),
        ChangeNotifierProvider(create: (_) => 
        GetSalonsProvider()),
        ChangeNotifierProvider(create: (_) => 
        GetSalonsSearchProvider())
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
          '/salons_screen':(context) => const SalonsScreen()
        },
      ),
    );
  }
}