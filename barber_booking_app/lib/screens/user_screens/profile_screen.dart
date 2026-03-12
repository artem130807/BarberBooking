import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:barber_booking_app/providers/auth_providers/auth_provider.dart';
import 'package:barber_booking_app/providers/user_providers/get_user_provider.dart';
import 'package:barber_booking_app/widgets/loading_indicator.dart';
import 'package:barber_booking_app/widgets/error_widget.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _selectedNavIndex = 4;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final token = authProvider.token;
    if (token == null) return;
    await Provider.of<GetUserProvider>(context, listen: false).getUser(token);
  }

  void _onNavItemTapped(int index) {
    setState(() {
      _selectedNavIndex = index;
    });
    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/home');
        break;
      case 1:
        Navigator.pushReplacementNamed(context, '/search_screen');
        break;
      case 2:
        Navigator.pushReplacementNamed(context, '/appointments_screen');
        break;
      case 3:
        Navigator.pushReplacementNamed(context, '/favorites_screen');
        break;
      case 4:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GetUserProvider>(
      builder: (context, provider, child) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (provider.errorMessage != null && mounted) {
            provider.showApiError(context, provider.errorMessage);
          }
        });

        return Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            title: const Text('Профиль'),
          ),
          body: _buildBody(provider),
          bottomNavigationBar: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            currentIndex: _selectedNavIndex,
            onTap: _onNavItemTapped,
            selectedItemColor: Colors.black,
            unselectedItemColor: Colors.grey,
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Главная'),
              BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Поиск'),
              BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: 'Записи'),
              BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Избранное'),
              BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Профиль'),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBody(GetUserProvider provider) {
    if (provider.isLoading && provider.userResponse == null) {
      return const Center(child: LoadingIndicator(message: 'Загрузка профиля...'));
    }

    if (provider.errorMessage != null && provider.userResponse == null) {
      return Center(
        child: ErrorWidgetCustom(
          message: provider.errorMessage!,
          onRetry: _loadUser,
        ),
      );
    }

    final user = provider.userResponse;
    if (user == null) {
      return const Center(
        child: Text(
          'Не удалось загрузить профиль',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const SizedBox(height: 20),
        // Аватар
        Center(
          child: CircleAvatar(
            radius: 60,
            backgroundColor: Colors.grey[300],
            child: const Icon(Icons.person, size: 60, color: Colors.grey),
          ),
        ),
        const SizedBox(height: 16),
        // Имя
        Center(
          child: Text(
            user.Name ?? 'Пользователь',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 8),
        // Email
        Center(
          child: Text(
            user.Email ?? 'email@example.com',
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ),
        const SizedBox(height: 4),
        // Город
        Center(
          child: Text(
            user.City ?? 'Город не указан',
            style: const TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ),
        const SizedBox(height: 40),
        // Пункты меню
        _buildMenuItem(
          icon: Icons.favorite,
          title: 'Избранное',
          onTap: () {
            Navigator.pushNamed(context, '/favorites_screen');
          },
        ),
        _buildMenuItem(
          icon: Icons.star,
          title: 'Ваши отзывы',
          onTap: () {
            // TODO: переход на экран отзывов пользователя
          },
        ),
        _buildMenuItem(
          icon: Icons.settings,
          title: 'Настройки',
          onTap: () {
            // TODO: переход на экран настроек
          },
        ),
        const SizedBox(height: 20),
        // Кнопка выхода
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: ElevatedButton(
            onPressed: () {
              // TODO: реализовать выход
              Provider.of<AuthProvider>(context, listen: false).logout();
              Navigator.pushReplacementNamed(context, '/login');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Выйти', style: TextStyle(fontSize: 16)),
          ),
        ),
      ],
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: Colors.black),
        title: Text(title, style: const TextStyle(fontSize: 16)),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}