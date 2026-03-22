import 'package:barber_booking_app/providers/auth_providers/auth_provider.dart';
import 'package:barber_booking_app/providers/user_providers/get_user_provider.dart';
import 'package:barber_booking_app/widgets/error_widget.dart';
import 'package:barber_booking_app/widgets/loading_indicator.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AdminProfileScreen extends StatefulWidget {
  const AdminProfileScreen({super.key});

  @override
  State<AdminProfileScreen> createState() => _AdminProfileScreenState();
}

class _AdminProfileScreenState extends State<AdminProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadUser());
  }

  Future<void> _loadUser() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final token = authProvider.token;
    if (token == null) return;
    await Provider.of<GetUserProvider>(context, listen: false).getUser(token);
  }

  Future<void> _onRefresh() async {
    await _loadUser();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GetUserProvider>(
      builder: (context, provider, _) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (provider.errorMessage != null && mounted) {
            provider.showApiError(context, provider.errorMessage);
          }
        });

        return Scaffold(
          appBar: AppBar(
            title: const Text('Профиль'),
            automaticallyImplyLeading: false,
          ),
          body: _buildBody(provider),
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
          style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        children: [
          const SizedBox(height: 12),
          Center(
            child: CircleAvatar(
              radius: 56,
              backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
              child: Icon(Icons.admin_panel_settings,
                  size: 56, color: Theme.of(context).colorScheme.primary),
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: Chip(
              avatar: Icon(Icons.shield, size: 18, color: Theme.of(context).colorScheme.primary),
              label: const Text('Администратор'),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              user.Name ?? 'Пользователь',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          const SizedBox(height: 4),
          Center(
            child: Text(
              user.Email ?? '',
              style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
            ),
          ),
          const SizedBox(height: 4),
          Center(
            child: Text(
              user.City ?? 'Город не указан',
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(height: 28),
          _tile(
            icon: Icons.settings,
            title: 'Настройки',
            onTap: () => Navigator.pushNamed(context, '/profile_settings'),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Material(
              color: Theme.of(context).colorScheme.error,
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                onTap: () {
                  Provider.of<AuthProvider>(context, listen: false).logout();
                  Navigator.pushNamedAndRemoveUntil(context, '/login', (r) => false);
                },
                borderRadius: BorderRadius.circular(12),
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

  Widget _tile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: theme.colorScheme.primary),
        title: Text(title, style: TextStyle(color: theme.colorScheme.onSurface)),
        trailing: Icon(Icons.chevron_right, color: theme.colorScheme.onSurfaceVariant),
        onTap: onTap,
      ),
    );
  }
}
