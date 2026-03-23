import 'package:flutter/material.dart';
import 'package:barber_booking_app/navigation/role_routes.dart';
import 'package:barber_booking_app/providers/auth_providers/auth_provider.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _passwordVisible = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (authProvider.errorMessage != null && mounted) {
            authProvider.showApiError(context, authProvider.errorMessage);
          }
        });

        return Scaffold(
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 40),
                  Center(
                    child: Icon(
                      Icons.cut,
                      size: 80,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: Text(
                      'BarberBooking',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                        color: Theme.of(context).colorScheme.onBackground,
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  Text(
                    'Добро пожаловать!',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onBackground,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Войдите чтобы продолжить',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Email поле
                  TextField(
                    controller: _emailController,
                    enabled: !authProvider.isLoading,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.email_outlined),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Пароль поле
                  TextField(
                    controller: _passwordController,
                    obscureText: !_passwordVisible,
                    enabled: !authProvider.isLoading,
                    decoration: InputDecoration(
                      labelText: 'Пароль',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _passwordVisible ? Icons.visibility_outlined : Icons.visibility_off_outlined, 
                        ),
                        onPressed: () {
                          setState(() {
                            _passwordVisible = !_passwordVisible;
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: authProvider.isLoading
                          ? null
                          : () => Navigator.pushNamed(context, '/forgot'),
                      child: const Text('Забыли пароль?'),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: authProvider.isLoading
                          ? null
                          : () async {
                              bool success = await authProvider.login(
                                _emailController.text.trim(),
                                _passwordController.text,
                              );
                              if (success && mounted) {
                                final route = RoleRoutes.homeRouteForRole(
                                  authProvider.roleInterface,
                                );
                                Navigator.pushReplacementNamed(context, route);
                              }
                            },
                      child: Text(
                        authProvider.isLoading ? 'Вход...' : 'Войти',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(child: Divider(color: Theme.of(context).colorScheme.outline)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'или',
                          style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                        ),
                      ),
                      Expanded(child: Divider(color: Theme.of(context).colorScheme.outline)),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Нет аккаунта?',
                        style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                      ),
                      TextButton(
                        onPressed: authProvider.isLoading
                            ? null
                            : () => Navigator.pushNamed(context, '/email-verification'),
                        child: const Text(
                          'Зарегистрироваться',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}