import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:barber_booking_app/models/user_models/responses/get_user_response.dart';
import 'package:barber_booking_app/screens/common/sessions_screen.dart';
import 'package:barber_booking_app/providers/auth_providers/auth_provider.dart';
import 'package:barber_booking_app/providers/user_providers/get_user_provider.dart';
import 'package:barber_booking_app/providers/user_providers/get_user_cities_provider.dart';
import 'package:barber_booking_app/providers/user_providers/update_user_city_provider.dart';
import 'package:barber_booking_app/widgets/loading_indicator.dart';

/// Экран настроек профиля: данные пользователя, смена города, смена пароля.
class ProfileSettingsScreen extends StatefulWidget {
  const ProfileSettingsScreen({super.key});

  @override
  State<ProfileSettingsScreen> createState() => _ProfileSettingsScreenState();
}

class _ProfileSettingsScreenState extends State<ProfileSettingsScreen> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final token = authProvider.token;
    if (token == null) return;

    final userProvider = Provider.of<GetUserProvider>(context, listen: false);
    final citiesProvider = Provider.of<GetUserCitiesProvider>(context, listen: false);

    await Future.wait([
      userProvider.getUser(),
      citiesProvider.loadCities(),
    ]);
  }

  Future<void> _openCityPicker(
    BuildContext context, {
    required String currentCity,
    required String? token,
  }) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.35),
      builder: (ctx) => _CityPickerSheet(
        initialCity: currentCity,
        token: token,
        onSaved: () async {
          await _loadData();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Настройки'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Consumer4<GetUserProvider, GetUserCitiesProvider, AuthProvider, UpdateUserCityProvider>(
        builder: (context, userProvider, citiesProvider, authProvider, updateCityProvider, _) {
          _postFrameError(userProvider);
          _postFrameError(citiesProvider);
          _postFrameError(updateCityProvider);

          if (userProvider.isLoading && userProvider.userResponse == null) {
            return const Center(
              child: LoadingIndicator(message: 'Загрузка настроек...'),
            );
          }

          final user = userProvider.userResponse;
          if (user == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Не удалось загрузить профиль',
                    style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: _loadData,
                    child: const Text('Повторить'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _loadData,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('Личные данные'),
                  _buildProfileCard(user),
                  const SizedBox(height: 28),
                  _buildSectionTitle('Город'),
                  _buildCityCard(
                    currentCity: user.City ?? 'Не указан',
                    cities: citiesProvider.cities,
                    isLoadingCities: citiesProvider.isLoading,
                    onTap: () {
                      final token = authProvider.token;
                      if (token == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Необходима авторизация'),
                            backgroundColor: Colors.orange,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                        return;
                      }
                      _openCityPicker(
                        context,
                        currentCity: user.City ?? '',
                        token: token,
                      );
                    },
                  ),
                  const SizedBox(height: 28),
                  _buildSectionTitle('Безопасность'),
                  _buildSecurityCard(
                    userEmail: user.Email,
                    onChangePassword: () {
                      Navigator.pushNamed(
                        context,
                        '/forgot',
                        arguments: user.Email,
                      );
                    },
                  ),
                  const SizedBox(height: 28),
                  _buildSectionTitle('Устройства'),
                  Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 8,
                      ),
                      leading: CircleAvatar(
                        backgroundColor:
                            Theme.of(context).colorScheme.surfaceContainerHighest,
                        child: Icon(
                          Icons.devices_rounded,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      title: const Text('Активные сессии'),
                      subtitle: Text(
                        'Управление входами на устройствах',
                        style: TextStyle(
                          fontSize: 13,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => Navigator.pushNamed(
                        context,
                        '/sessions',
                        arguments: const SessionsRouteArgs(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _postFrameError(dynamic provider) {
    if (provider is GetUserProvider || provider is GetUserCitiesProvider || provider is UpdateUserCityProvider) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && provider.errorMessage != null) {
          provider.showApiError(context, provider.errorMessage);
        }
      });
    }
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 10),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildProfileCard(GetUserResponse user) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Theme.of(context).colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildInfoRow(Icons.person_outline, 'Имя', user.Name ?? '—'),
            const Divider(height: 24),
            _buildInfoRow(Icons.email_outlined, 'Email', user.Email ?? '—'),
            const Divider(height: 24),
            _buildInfoRow(Icons.location_city_outlined, 'Город', user.City ?? 'Не указан'),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 22, color: Theme.of(context).colorScheme.onSurfaceVariant),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCityCard({
    required String currentCity,
    required List<String> cities,
    required bool isLoadingCities,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
          child: Icon(
            Icons.location_city_outlined,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        title: Text(
          'Изменить город',
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        subtitle: Text(
          currentCity,
          style: TextStyle(
            fontSize: 14,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        trailing: cities.isEmpty && isLoadingCities
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }

  Widget _buildSecurityCard({
    required String? userEmail,
    required VoidCallback onChangePassword,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
          child: Icon(
            Icons.lock_outline,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        title: Text(
          'Сменить пароль',
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        subtitle: Text(
          'На почту придёт код подтверждения',
          style: TextStyle(
            fontSize: 13,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: onChangePassword,
      ),
    );
  }
}

/// Нижний лист выбора города из списка GetUserCitiesProvider с поиском по названию.
class _CityPickerSheet extends StatefulWidget {
  final String initialCity;
  final String? token;
  final VoidCallback onSaved;

  const _CityPickerSheet({
    required this.initialCity,
    required this.token,
    required this.onSaved,
  });

  @override
  State<_CityPickerSheet> createState() => _CityPickerSheetState();
}

class _CityPickerSheetState extends State<_CityPickerSheet> {
  late String _selectedCity;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();
  Timer? _searchDebounce;

  @override
  void initState() {
    super.initState();
    _selectedCity = widget.initialCity;
    final citiesProvider = Provider.of<GetUserCitiesProvider>(context, listen: false);
    if (citiesProvider.cities.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) citiesProvider.loadCities();
      });
    }
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final token = widget.token;
    if (token == null) return;
    final updateProvider = Provider.of<UpdateUserCityProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final updated =
        await updateProvider.updateCity(_selectedCity, authProvider);
    if (!mounted) return;
    if (updated != null) {
      await Provider.of<GetUserProvider>(context, listen: false).getUser();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Город успешно обновлён'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pop(context);
        widget.onSaved();
      }
    } else {
      updateProvider.showApiError(context, updateProvider.errorMessage);
    }
  }

  void _onSearchChanged(String value) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 350), () {
      if (!mounted) return;
      final search = _searchController.text.trim();
      Provider.of<GetUserCitiesProvider>(context, listen: false).loadCities(
        search: search.isEmpty ? null : search,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<GetUserCitiesProvider, UpdateUserCityProvider>(
      builder: (context, citiesProvider, updateProvider, _) {
        final cities = citiesProvider.cities;
        final isLoadingCities = citiesProvider.isLoading;
        final isSaving = updateProvider.isLoading;
        final screenHeight = MediaQuery.of(context).size.height;
        return Container(
          constraints: BoxConstraints(
            minHeight: screenHeight * 0.5,
            maxHeight: screenHeight * 0.85,
          ),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.outline,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                child: Row(
                  children: [
                    Text(
                      'Выберите город',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: isSaving ? null : _save,
                      child: Text(isSaving ? 'Сохранение...' : 'Сохранить'),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: TextField(
                  controller: _searchController,
                  focusNode: _searchFocus,
                  onChanged: _onSearchChanged,
                  decoration: InputDecoration(
                    hintText: 'Поиск по названию города...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    isDense: true,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              const Divider(height: 1),
              Flexible(
                child: isLoadingCities && cities.isEmpty
                    ? const Padding(
                        padding: EdgeInsets.all(24),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    : cities.isEmpty
                        ? Padding(
                            padding: EdgeInsets.all(24),
                            child: Center(
                              child: Text(
                                'Ничего не найдено. Введите название или очистите поиск.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ),
                          )
                        : ListView.builder(
                            shrinkWrap: true,
                            itemCount: cities.length,
                            itemBuilder: (context, index) {
                              final city = cities[index];
                              final isSelected = _selectedCity == city;
                              return ListTile(
                                title: Text(city),
                                trailing: isSelected
                                    ? Icon(
                                        Icons.check,
                                        color: Theme.of(context).colorScheme.primary,
                                      )
                                    : null,
                                onTap: () => setState(() => _selectedCity = city),
                              );
                            },
                          ),
              ),
            ],
          ),
        );
      },
    );
  }
}
