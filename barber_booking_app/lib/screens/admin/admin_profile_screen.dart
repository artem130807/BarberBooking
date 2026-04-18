import 'package:barber_booking_app/screens/common/sessions_screen.dart';
import 'package:barber_booking_app/providers/auth_providers/auth_provider.dart';
import 'package:barber_booking_app/providers/user_providers/get_user_provider.dart';
import 'package:barber_booking_app/widgets/error_widget.dart';
import 'package:barber_booking_app/widgets/loading_indicator.dart';
import 'package:barber_booking_app/widgets/profile_shell_widgets.dart';
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
    await Provider.of<GetUserProvider>(context, listen: false).getUser();
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
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

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
          style: TextStyle(color: cs.onSurfaceVariant),
        ),
      );
    }

    final email = user.Email?.trim();
    final city = user.City?.trim();
    final cityDisplay =
        city != null && city.isNotEmpty ? city : 'Не указан';

    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          const SizedBox(height: 8),
          Center(
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: cs.outline.withValues(alpha: 0.35),
                      width: 2,
                    ),
                  ),
                  child: ClipOval(
                    child: SizedBox(
                      width: 104,
                      height: 104,
                      child: ColoredBox(
                        color: cs.surfaceContainerHighest,
                        child: Icon(
                          Icons.admin_panel_settings_rounded,
                          size: 52,
                          color: cs.primary,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Chip(
                  avatar: Icon(Icons.shield_rounded, size: 18, color: cs.primary),
                  label: const Text('Администратор'),
                  visualDensity: VisualDensity.compact,
                  side: BorderSide(color: cs.outline.withValues(alpha: 0.25)),
                ),
                const SizedBox(height: 10),
                Text(
                  user.Name ?? 'Пользователь',
                  textAlign: TextAlign.center,
                  style: tt.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          ProfileSectionHeading(text: 'Контакты', colorScheme: cs),
          Card(
            margin: EdgeInsets.zero,
            clipBehavior: Clip.antiAlias,
            shape: profileCardShape(cs),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
              child: Column(
                children: [
                  ProfileLabeledRow(
                    icon: Icons.mail_outlined,
                    title: 'Email',
                    value: email ?? '—',
                    colorScheme: cs,
                    valueWidget: email != null && email.isNotEmpty
                        ? SelectableText(
                            email,
                            style: tt.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: cs.onSurface,
                            ),
                          )
                        : Text(
                            '—',
                            style: tt.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                  Divider(
                    height: 1,
                    color: cs.outlineVariant.withValues(alpha: 0.45),
                  ),
                  ProfileLabeledRow(
                    icon: Icons.place_outlined,
                    title: 'Город',
                    value: cityDisplay,
                    colorScheme: cs,
                    valueWidget: city == null || city.isEmpty
                        ? Text(
                            cityDisplay,
                            style: tt.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w500,
                              color: cs.onSurfaceVariant,
                            ),
                          )
                        : null,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          ProfileSectionHeading(text: 'Действия', colorScheme: cs),
          Card(
            margin: EdgeInsets.zero,
            clipBehavior: Clip.antiAlias,
            shape: profileCardShape(cs),
            child: Column(
              children: [
                ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  leading: Icon(Icons.settings_outlined, color: cs.primary),
                  title: const Text('Настройки'),
                  trailing: Icon(
                    Icons.chevron_right_rounded,
                    color: cs.onSurfaceVariant.withValues(alpha: 0.7),
                  ),
                  onTap: () =>
                      Navigator.pushNamed(context, '/profile_settings'),
                ),
                Divider(
                  height: 1,
                  indent: 56,
                  color: cs.outlineVariant.withValues(alpha: 0.45),
                ),
                ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  leading: Icon(Icons.devices_rounded, color: cs.primary),
                  title: const Text('Активные сессии'),
                  subtitle: Text(
                    'Устройства, с которых выполнен вход',
                    style: TextStyle(
                      fontSize: 13,
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                  trailing: Icon(
                    Icons.chevron_right_rounded,
                    color: cs.onSurfaceVariant.withValues(alpha: 0.7),
                  ),
                  onTap: () => Navigator.pushNamed(
                    context,
                    '/sessions',
                    arguments: const SessionsRouteArgs(),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: cs.error,
                foregroundColor: cs.onError,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                Provider.of<AuthProvider>(context, listen: false).logout();
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/login',
                  (r) => false,
                );
              },
              child: const Text(
                'Выйти',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
