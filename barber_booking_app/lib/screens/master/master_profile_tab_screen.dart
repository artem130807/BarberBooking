import 'package:barber_booking_app/models/master_models/response/get_master_response.dart';
import 'package:barber_booking_app/providers/auth_providers/auth_provider.dart';
import 'package:barber_booking_app/providers/master_providers/master_session_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MasterProfileTabScreen extends StatelessWidget {
  const MasterProfileTabScreen({super.key, required this.profile});

  final GetMasterResponse profile;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final salonName = profile.SalonNavigation?.SalonName ?? 'Салон';
    final rating = profile.Rating;
    final count = profile.RatingCount ?? 0;

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
                child: profile.AvatarUrl != null && profile.AvatarUrl!.isNotEmpty
                    ? Image.network(
                        profile.AvatarUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => ColoredBox(
                          color: cs.surfaceContainerHighest,
                          child: Icon(Icons.person, size: 56, color: cs.primary),
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
          const SizedBox(height: 4),
          Center(
            child: Text(
              salonName,
              style: TextStyle(color: cs.onSurfaceVariant),
            ),
          ),
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
            const SizedBox(height: 16),
            Text(
              'Специализация',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 4),
            Text(
              profile.Specialization!,
              style: TextStyle(color: cs.onSurfaceVariant, height: 1.35),
            ),
          ],
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
