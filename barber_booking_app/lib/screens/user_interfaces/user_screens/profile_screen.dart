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

  GetUserProvider? _userForApiErrors;

  void _onUserApiError() {
    if (!mounted) return;
    final p = _userForApiErrors;
    if (p == null) return;
    final msg = p.errorMessage;
    if (msg != null && msg.isNotEmpty) p.showApiError(context, msg);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_userForApiErrors != null) return;
    final p = context.read<GetUserProvider>();
    _userForApiErrors = p;
    p.addListener(_onUserApiError);
  }

  @override
  void dispose() {
    _userForApiErrors?.removeListener(_onUserApiError);
    super.dispose();
  }

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

  Future<void> _onRefreshProfile() async {
    await _loadUser();
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
        return Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            title: const Text('Профиль'),
            elevation: 0,
          ),
          body: _buildBody(provider),
          bottomNavigationBar: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            currentIndex: _selectedNavIndex,
            onTap: _onNavItemTapped,
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
      return Center(
        child: Text(
          'Не удалось загрузить профиль',
          style: TextStyle(fontSize: 16, color: Theme.of(context).colorScheme.onSurfaceVariant),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _onRefreshProfile,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        children: [
        const SizedBox(height: 20),
        // Аватар
        Center(
          child: CircleAvatar(
            radius: 60,
            backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
            child: Icon(Icons.person, size: 60, color: Theme.of(context).colorScheme.onSurfaceVariant),
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
            style: TextStyle(fontSize: 16, color: Theme.of(context).colorScheme.onSurfaceVariant),
          ),
        ),
        const SizedBox(height: 4),
        // Город
        Center(
          child: Text(
            user.City ?? 'Город не указан',
            style: TextStyle(fontSize: 14, color: Theme.of(context).colorScheme.onSurfaceVariant),
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
            Navigator.pushNamed(context, '/user_reviews');
          },
        ),
        _buildMenuItem(
          icon: Icons.settings,
          title: 'Настройки',
          onTap: () {
            Navigator.pushNamed(context, '/profile_settings');
          },
        ),
        const SizedBox(height: 20),
        // Кнопка выхода
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Material(
            color: Theme.of(context).colorScheme.error,
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              onTap: () {
                Provider.of<AuthProvider>(context, listen: false).logout();
                Navigator.pushReplacementNamed(context, '/login');
              },
              borderRadius: BorderRadius.circular(12),
              splashColor: Colors.white24,
              highlightColor: Colors.white12,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                alignment: Alignment.center,
                child: Text(
                  'Выйти',
                  style: TextStyle(
                    fontSize: 16,
                    color: Theme.of(context).colorScheme.onError,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
      ),
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
        leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
        title: Text(title, style: const TextStyle(fontSize: 16)),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}