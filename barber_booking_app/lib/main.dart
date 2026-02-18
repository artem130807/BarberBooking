import 'package:flutter/material.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/home_screen.dart';
import 'screens/auth/forgot_password_screen.dart';
import 'screens/auth/email_verification_screen.dart';
import 'screens/auth/verify_code_screen.dart';
import 'screens/auth/veify_code_updatepassword_screen.dart';
import 'screens/auth/update_password_screen.dart';
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
          '/update-password': (context) => const UpdatePasswordScreen()
        },
      ),
    );
  }
}