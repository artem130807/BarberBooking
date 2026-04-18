import 'package:barber_booking_app/providers/auth_providers/auth_provider.dart';
import 'package:barber_booking_app/providers/user_providers/get_user_provider.dart';
import 'package:barber_booking_app/widgets/error_widget.dart';
import 'package:barber_booking_app/widgets/loading_indicator.dart';
import 'package:barber_booking_app/widgets/profile_shell_widgets.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
    await Provider.of<GetUserProvider>(context, listen: false).getUser();
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
          ),
          body: _buildBody(provider),
          bottomNavigationBar: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            currentIndex: _selectedNavIndex,
            onTap: _onNavItemTapped,
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Главная'),
              BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Поиск'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.calendar_today), label: 'Записи'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.favorite), label: 'Избранное'),
              BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Профиль'),
            ],
          ),
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
      onRefresh: _onRefreshProfile,
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
                          Icons.person_rounded,
                          size: 52,
                          color: cs.primary,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Chip(
                  avatar: Icon(Icons.face_rounded, size: 18, color: cs.primary),
                  label: const Text('Клиент'),
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
          ProfileSectionHeading(text: 'Меню', colorScheme: cs),
          Card(
            margin: EdgeInsets.zero,
            clipBehavior: Clip.antiAlias,
            shape: profileCardShape(cs),
            child: Column(
              children: [
                ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  leading: Icon(Icons.favorite_outline_rounded, color: cs.primary),
                  title: const Text('Избранное'),
                  trailing: Icon(
                    Icons.chevron_right_rounded,
                    color: cs.onSurfaceVariant.withValues(alpha: 0.7),
                  ),
                  onTap: () =>
                      Navigator.pushNamed(context, '/favorites_screen'),
                ),
                Divider(
                  height: 1,
                  indent: 56,
                  color: cs.outlineVariant.withValues(alpha: 0.45),
                ),
                ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  leading: Icon(Icons.star_outline_rounded, color: cs.primary),
                  title: const Text('Ваши отзывы'),
                  trailing: Icon(
                    Icons.chevron_right_rounded,
                    color: cs.onSurfaceVariant.withValues(alpha: 0.7),
                  ),
                  onTap: () => Navigator.pushNamed(context, '/user_reviews'),
                ),
                Divider(
                  height: 1,
                  indent: 56,
                  color: cs.outlineVariant.withValues(alpha: 0.45),
                ),
                ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  leading:
                      Icon(Icons.settings_outlined, color: cs.primary),
                  title: const Text('Настройки'),
                  trailing: Icon(
                    Icons.chevron_right_rounded,
                    color: cs.onSurfaceVariant.withValues(alpha: 0.7),
                  ),
                  onTap: () =>
                      Navigator.pushNamed(context, '/profile_settings'),
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
