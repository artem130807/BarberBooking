import 'package:barber_booking_app/models/master_models/response/get_master_response.dart';
import 'package:barber_booking_app/providers/auth_providers/auth_provider.dart';
import 'package:barber_booking_app/providers/master_providers/master_session_provider.dart';
import 'package:barber_booking_app/providers/message_providers/get_count_messages_provider.dart';
import 'package:barber_booking_app/screens/master/master_edit_profile_screen.dart';
import 'package:barber_booking_app/screens/master/master_my_services_screen.dart';
import 'package:barber_booking_app/screens/master/master_my_reviews_screen.dart';
import 'package:barber_booking_app/screens/master/master_statistics_screen.dart';
import 'package:barber_booking_app/widgets/master/master_notification_app_bar_button.dart';
import 'package:barber_booking_app/widgets/profile_shell_widgets.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MasterProfileTabScreen extends StatelessWidget {
  const MasterProfileTabScreen({super.key, required this.profile});

  final GetMasterResponse profile;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final salonName = profile.SalonNavigation?.SalonName ?? 'Салон';
    final rating = profile.Rating;
    final count = profile.RatingCount ?? 0;
    final hasAbout = (profile.Specialization != null &&
            profile.Specialization!.trim().isNotEmpty) ||
        (profile.Bio != null && profile.Bio!.trim().isNotEmpty);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Профиль'),
        automaticallyImplyLeading: false,
        actions: const [MasterNotificationAppBarButton()],
      ),
      body: ListView(
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
                      child: profile.AvatarUrl != null &&
                              profile.AvatarUrl!.isNotEmpty
                          ? Image.network(
                              profile.AvatarUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => ColoredBox(
                                color: cs.surfaceContainerHighest,
                                child: Icon(
                                  Icons.person_rounded,
                                  size: 52,
                                  color: cs.primary,
                                ),
                              ),
                            )
                          : ColoredBox(
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
                  avatar: Icon(Icons.content_cut_rounded,
                      size: 18, color: cs.primary),
                  label: const Text('Мастер'),
                  visualDensity: VisualDensity.compact,
                  side: BorderSide(color: cs.outline.withValues(alpha: 0.25)),
                ),
                const SizedBox(height: 10),
                Text(
                  profile.UserName ?? 'Мастер',
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
          ProfileSectionHeading(text: 'Салон', colorScheme: cs),
          Card(
            margin: EdgeInsets.zero,
            clipBehavior: Clip.antiAlias,
            shape: profileCardShape(cs),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
              child: ProfileLabeledRow(
                icon: Icons.storefront_rounded,
                title: 'Салон',
                value: salonName,
                colorScheme: cs,
              ),
            ),
          ),
          if (profile.Id != null && profile.Id!.isNotEmpty) ...[
            const SizedBox(height: 20),
            ProfileSectionHeading(text: 'Рейтинг', colorScheme: cs),
            Card(
              margin: EdgeInsets.zero,
              clipBehavior: Clip.antiAlias,
              shape: profileCardShape(cs),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () {
                    Navigator.of(context).push<void>(
                      MaterialPageRoute(
                        builder: (_) => MasterMyReviewsScreen(
                          masterId: profile.Id!,
                          masterName: profile.UserName,
                        ),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 16,
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: cs.primaryContainer,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.star_rounded,
                            color: cs.primary,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                rating != null
                                    ? rating.toStringAsFixed(1)
                                    : '—',
                                style: tt.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                count == 0
                                    ? 'Нет оценок'
                                    : (count == 1
                                        ? '1 оценка'
                                        : '$count ${_ratingWord(count)}'),
                                style: TextStyle(
                                  color: cs.onSurfaceVariant,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Отзывы клиентов',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: cs.primary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.chevron_right_rounded,
                          color: cs.onSurfaceVariant.withValues(alpha: 0.65),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
          if (hasAbout) ...[
            const SizedBox(height: 20),
            ProfileSectionHeading(text: 'О мастере', colorScheme: cs),
            Card(
              margin: EdgeInsets.zero,
              clipBehavior: Clip.antiAlias,
              shape: profileCardShape(cs),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (profile.Specialization != null &&
                        profile.Specialization!.trim().isNotEmpty) ...[
                      Text(
                        'Специализация',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.15,
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        profile.Specialization!.trim(),
                        style: tt.bodyLarge?.copyWith(height: 1.4),
                      ),
                    ],
                    if (profile.Bio != null &&
                        profile.Bio!.trim().isNotEmpty) ...[
                      if (profile.Specialization != null &&
                          profile.Specialization!.trim().isNotEmpty)
                        const SizedBox(height: 18),
                      Text(
                        'О себе',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.15,
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        profile.Bio!.trim(),
                        style: TextStyle(
                          color: cs.onSurfaceVariant,
                          height: 1.45,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
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
                  leading: Icon(Icons.edit_outlined, color: cs.primary),
                  title: const Text('Редактировать профиль'),
                  trailing: Icon(
                    Icons.chevron_right_rounded,
                    color: cs.onSurfaceVariant.withValues(alpha: 0.7),
                  ),
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
                  height: 1,
                  indent: 56,
                  color: cs.outlineVariant.withValues(alpha: 0.45),
                ),
                ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  leading: Icon(Icons.spa_outlined, color: cs.primary),
                  title: const Text('Мои услуги'),
                  subtitle: Text(
                    'Услуги салона, по которым вы принимаете записи',
                    style: TextStyle(
                      fontSize: 13,
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                  trailing: Icon(
                    Icons.chevron_right_rounded,
                    color: cs.onSurfaceVariant.withValues(alpha: 0.7),
                  ),
                  onTap: () {
                    final mid = profile.Id;
                    if (mid == null || mid.isEmpty) return;
                    Navigator.of(context).push<void>(
                      MaterialPageRoute(
                        builder: (_) => MasterMyServicesScreen(
                          masterProfileId: mid,
                        ),
                      ),
                    );
                  },
                ),
                Divider(
                  height: 1,
                  indent: 56,
                  color: cs.outlineVariant.withValues(alpha: 0.45),
                ),
                ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  leading: Icon(Icons.notifications_outlined, color: cs.primary),
                  title: const Text('Уведомления'),
                  subtitle: Consumer<GetCountMessagesProvider>(
                    builder: (context, count, _) {
                      if (count.count <= 0) {
                        return Text(
                          'Нет непрочитанных',
                          style: TextStyle(
                            fontSize: 13,
                            color: cs.onSurfaceVariant,
                          ),
                        );
                      }
                      return Text(
                        '${count.count} непрочитанных',
                        style: TextStyle(
                          fontSize: 13,
                          color: cs.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      );
                    },
                  ),
                  trailing: Icon(
                    Icons.chevron_right_rounded,
                    color: cs.onSurfaceVariant.withValues(alpha: 0.7),
                  ),
                  onTap: () async {
                    await Navigator.pushNamed(context, '/master_notifications');
                    if (!context.mounted) return;
                    final token = context.read<AuthProvider>().token;
                    await context.read<GetCountMessagesProvider>().loadCount(token);
                  },
                ),
                Divider(
                  height: 1,
                  indent: 56,
                  color: cs.outlineVariant.withValues(alpha: 0.45),
                ),
                ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  leading: Icon(Icons.analytics_outlined, color: cs.primary),
                  title: const Text('Статистика'),
                  subtitle: Text(
                    'Завершения, отмены, суммы',
                    style: TextStyle(
                      fontSize: 13,
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                  trailing: Icon(
                    Icons.chevron_right_rounded,
                    color: cs.onSurfaceVariant.withValues(alpha: 0.7),
                  ),
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
                context.read<MasterSessionProvider>().clear();
                context.read<AuthProvider>().logout();
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

  static String _ratingWord(int n) {
    final m10 = n % 10;
    final m100 = n % 100;
    if (m100 >= 11 && m100 <= 14) return 'оценок';
    if (m10 == 1) return 'оценка';
    if (m10 >= 2 && m10 <= 4) return 'оценки';
    return 'оценок';
  }
}
