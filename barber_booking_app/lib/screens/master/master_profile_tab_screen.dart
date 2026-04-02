import 'package:barber_booking_app/models/master_models/response/get_master_response.dart';
import 'package:barber_booking_app/models/salon_models/response/salon_navigation_response.dart';
import 'package:barber_booking_app/providers/auth_providers/auth_provider.dart';
import 'package:barber_booking_app/providers/master_providers/master_session_provider.dart';
import 'package:barber_booking_app/screens/master/master_edit_profile_screen.dart';
import 'package:barber_booking_app/screens/master/master_statistics_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MasterProfileTabScreen extends StatelessWidget {
  const MasterProfileTabScreen({super.key, required this.profile});

  final GetMasterResponse profile;

  String _addressLine(SalonNavigationResponse? s) {
    final a = s?.Address;
    if (a == null) return '';
    final parts = <String>[];
    final city = a.City;
    if (city != null && city.isNotEmpty) parts.add(city);
    final street = a.Street;
    if (street != null && street.isNotEmpty) parts.add(street);
    final house = a.HouseNumber;
    if (house != null && house.isNotEmpty) parts.add('д. $house');
    final apt = a.Apartment;
    if (apt != null && apt.isNotEmpty) parts.add('кв. $apt');
    return parts.join(', ');
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final salonName = profile.SalonNavigation?.SalonName ?? 'Салон';
    final rating = profile.Rating;
    final count = profile.RatingCount ?? 0;
    final addr = _addressLine(profile.SalonNavigation);
    final phone = profile.MasterPhone;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Профиль'),
        automaticallyImplyLeading: false,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SizedBox(height: 8),
          Center(
            child: SizedBox(
              width: 112,
              height: 112,
              child: ClipOval(
                child: profile.AvatarUrl != null &&
                        profile.AvatarUrl!.isNotEmpty
                    ? Image.network(
                        profile.AvatarUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => ColoredBox(
                          color: cs.surfaceContainerHighest,
                          child:
                              Icon(Icons.person, size: 56, color: cs.primary),
                        ),
                      )
                    : ColoredBox(
                        color: cs.surfaceContainerHighest,
                        child: Icon(Icons.person, size: 56, color: cs.primary),
                      ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: Chip(
              avatar: Icon(Icons.content_cut, size: 18, color: cs.primary),
              label: const Text('Мастер'),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              profile.UserName ?? 'Мастер',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: cs.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Салон',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.2,
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      salonName,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (addr.isNotEmpty) ...[
            const SizedBox(height: 8),
            Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.place_outlined,
                      size: 18, color: cs.onSurfaceVariant),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      addr,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: cs.onSurfaceVariant, height: 1.3),
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (phone != null && phone.isNotEmpty) ...[
            const SizedBox(height: 8),
            Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.phone_outlined,
                      size: 18, color: cs.onSurfaceVariant),
                  const SizedBox(width: 6),
                  SelectableText(
                    phone,
                    style: TextStyle(
                      color: cs.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (rating != null) ...[
            const SizedBox(height: 12),
            Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.star, color: cs.primary, size: 22),
                  const SizedBox(width: 6),
                  Text(
                    rating.toStringAsFixed(1),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '($count)',
                    style: TextStyle(color: cs.onSurfaceVariant),
                  ),
                ],
              ),
            ),
          ],
          if (profile.Specialization != null &&
              profile.Specialization!.isNotEmpty) ...[
            const SizedBox(height: 20),
            Text(
              'Специализация',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 6),
            Text(
              profile.Specialization!,
              style: TextStyle(color: cs.onSurfaceVariant, height: 1.4),
            ),
          ],
          if (profile.Bio != null && profile.Bio!.isNotEmpty) ...[
            const SizedBox(height: 20),
            Text(
              'О себе',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 6),
            Text(
              profile.Bio!,
              style: TextStyle(color: cs.onSurfaceVariant, height: 1.45),
            ),
          ],
          const SizedBox(height: 24),
          Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Column(
              children: [
                ListTile(
                  leading: Icon(Icons.edit_outlined, color: cs.primary),
                  title: const Text('Редактировать профиль'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.of(context).push<void>(
                      MaterialPageRoute(
                        builder: (_) =>
                            MasterEditProfileScreen(profile: profile),
                      ),
                    );
                  },
                ),
                Divider(
                    height: 1, color: cs.outlineVariant.withValues(alpha: 0.5)),
                ListTile(
                  leading: Icon(Icons.analytics_outlined, color: cs.primary),
                  title: const Text('Статистика'),
                  subtitle: const Text('Завершения, отмены, суммы'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.of(context).push<void>(
                      MaterialPageRoute(
                        builder: (_) => const MasterStatisticsScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Material(
              color: cs.error,
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                onTap: () {
                  context.read<MasterSessionProvider>().clear();
                  context.read<AuthProvider>().logout();
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/login',
                    (r) => false,
                  );
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
                      color: cs.onError,
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
}
