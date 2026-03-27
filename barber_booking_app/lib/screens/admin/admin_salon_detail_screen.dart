import 'package:barber_booking_app/providers/auth_providers/auth_provider.dart';
import 'package:barber_booking_app/providers/salon_providers/get_salon_admin_stats_provider.dart';
import 'package:barber_booking_app/widgets/error_widget.dart';
import 'package:barber_booking_app/widgets/loading_indicator.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class AdminSalonDetailScreen extends StatefulWidget {
  const AdminSalonDetailScreen({super.key, required this.salonId});

  final String salonId;

  @override
  State<AdminSalonDetailScreen> createState() => _AdminSalonDetailScreenState();
}

class _AdminSalonDetailScreenState extends State<AdminSalonDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    final token = context.read<AuthProvider>().token;
    await context.read<GetSalonAdminStatsProvider>().load(widget.salonId, token);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final df = DateFormat('dd.MM.yyyy');

    return Scaffold(
      appBar: AppBar(
        title: Consumer<GetSalonAdminStatsProvider>(
          builder: (context, p, _) {
            final n = p.stats?.Name;
            return Text(n != null && n.isNotEmpty ? n : 'Салон');
          },
        ),
      ),
      body: Consumer<GetSalonAdminStatsProvider>(
        builder: (context, prov, _) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (prov.errorMessage != null && mounted) {
              prov.showApiError(context, prov.errorMessage);
            }
          });

          if (prov.isLoading && prov.stats == null) {
            return const Center(child: LoadingIndicator(message: 'Загрузка...'));
          }

          if (prov.errorMessage != null && prov.stats == null) {
            return Center(
              child: ErrorWidgetCustom(
                message: prov.errorMessage!,
                onRetry: _load,
              ),
            );
          }

          final s = prov.stats;
          if (s == null) {
            return const Center(child: Text('Нет данных'));
          }

          return RefreshIndicator(
            onRefresh: _load,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        icon: Icons.star_rounded,
                        label: 'Рейтинг',
                        value: s.Rating != null
                            ? s.Rating!.toStringAsFixed(1)
                            : '—',
                        subtitle: '${s.RatingCount ?? 0} оценок',
                        color: cs.primaryContainer,
                        onPrimary: cs.onPrimaryContainer,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _StatCard(
                        icon: s.IsActive == true
                            ? Icons.check_circle_outline
                            : Icons.pause_circle_outline,
                        label: 'Статус',
                        value: s.IsActive == true ? 'Активен' : 'Неактивен',
                        subtitle: s.CreatedAt != null
                            ? 'с ${df.format(s.CreatedAt!.toLocal())}'
                            : '',
                        color: cs.secondaryContainer,
                        onPrimary: cs.onSecondaryContainer,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Показатели',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 10),
                _MetricTile(
                  icon: Icons.content_cut_rounded,
                  title: 'Услуги',
                  value: '${s.ServicesCount ?? 0}',
                  onTap: () => Navigator.pushNamed(
                    context,
                    '/admin_salon_services',
                    arguments: widget.salonId,
                  ),
                ),
                _MetricTile(
                  icon: Icons.person_outline_rounded,
                  title: 'Мастера',
                  value: '${s.MastersCount ?? 0}',
                  onTap: () => Navigator.pushNamed(
                    context,
                    '/admin_salon_masters',
                    arguments: widget.salonId,
                  ),
                ),
                _MetricTile(
                  icon: Icons.event_note_outlined,
                  title: 'Записи',
                  value: '${s.AppointmentsCount ?? 0}',
                  onTap: () => Navigator.pushNamed(
                    context,
                    '/admin_salon_appointments',
                    arguments: widget.salonId,
                  ),
                ),
                _MetricTile(
                  icon: Icons.reviews_outlined,
                  title: 'Отзывы',
                  value: '${s.ReviewsCount ?? 0}',
                  onTap: () => Navigator.pushNamed(
                    context,
                    '/admin_salon_reviews',
                    arguments: widget.salonId,
                  ),
                ),
                _MetricTile(
                  icon: Icons.insights_outlined,
                  title: 'Статистика',
                  value: 'Сводка · снимки',
                  onTap: () => Navigator.pushNamed(
                    context,
                    '/admin_salon_statistics',
                    arguments: widget.salonId,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.subtitle,
    required this.color,
    required this.onPrimary,
  });

  final IconData icon;
  final String label;
  final String value;
  final String subtitle;
  final Color color;
  final Color onPrimary;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: color.withValues(alpha: 0.85),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: onPrimary, size: 22),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: onPrimary.withValues(alpha: 0.85),
              ),
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: onPrimary,
              ),
            ),
            if (subtitle.isNotEmpty)
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 11,
                  color: onPrimary.withValues(alpha: 0.75),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({
    required this.icon,
    required this.title,
    required this.value,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String value;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final titleStyle = Theme.of(context).textTheme.titleMedium;
    final valueStyle = Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w700,
        );
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 0,
      color: cs.surfaceContainerHighest.withValues(alpha: 0.4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: cs.outline.withValues(alpha: 0.12)),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(icon, color: cs.primary, size: 22),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: Text(
                  title,
                  style: titleStyle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 3,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    value,
                    style: valueStyle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.end,
                  ),
                ),
              ),
              if (onTap != null) ...[
                const SizedBox(width: 4),
                Icon(Icons.chevron_right_rounded, color: cs.onSurfaceVariant, size: 22),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
