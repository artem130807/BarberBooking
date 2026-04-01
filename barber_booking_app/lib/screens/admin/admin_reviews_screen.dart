import 'package:barber_booking_app/utils/admin_last_salon_storage.dart';
import 'package:barber_booking_app/services/admin_export/admin_excel_export_service.dart';
import 'package:barber_booking_app/services/review_services/get_reviews_admin_service.dart';
import 'package:barber_booking_app/models/params/page_params.dart';
import 'package:barber_booking_app/models/params/review_params/review_admin_filter.dart';
import 'package:barber_booking_app/models/params/salon_params/salon_filter.dart';
import 'package:barber_booking_app/providers/auth_providers/auth_provider.dart';
import 'package:barber_booking_app/providers/review_providers/get_reviews_admin_provider.dart';
import 'package:barber_booking_app/providers/salon_providers/get_salons_provider.dart';
import 'package:barber_booking_app/widgets/admin_widgets/admin_reviews_filter_panel.dart';
import 'package:barber_booking_app/widgets/error_widget.dart';
import 'package:barber_booking_app/widgets/loading_indicator.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class AdminReviewsScreen extends StatefulWidget {
  const AdminReviewsScreen({super.key, this.initialSalonId});

  /// Если задан — фильтр по салону и загрузка сразу (экран из карточки салона).
  final String? initialSalonId;

  @override
  State<AdminReviewsScreen> createState() => _AdminReviewsScreenState();
}

class _AdminReviewsScreenState extends State<AdminReviewsScreen> {
  final SalonFilter _salonListFilter = SalonFilter();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _loadSalons();
      final sid = widget.initialSalonId;
      if (sid != null && sid.isNotEmpty && mounted) {
        context.read<GetReviewsAdminProvider>().setActiveFilter(
              ReviewAdminFilter(salonId: sid),
            );
        await AdminLastSalonStorage.write(sid);
      } else {
        final saved = await AdminLastSalonStorage.read();
        if (!mounted) return;
        final list = context.read<GetSalonsProvider>().getSalonsResponse ?? [];
        if (saved != null &&
            saved.isNotEmpty &&
            list.any((e) => e.Id == saved)) {
          context.read<GetReviewsAdminProvider>().setActiveFilter(
                ReviewAdminFilter(salonId: saved),
              );
        }
      }
      if (mounted) await _reloadList();
    });
  }

  Future<void> _loadSalons() async {
    final token = context.read<AuthProvider>().token;
    await context.read<GetSalonsProvider>().getSalons(
          PageParams(Page: 1, PageSize: 200),
          _salonListFilter,
          token,
        );
  }

  Future<void> _reloadList() async {
    final token = context.read<AuthProvider>().token;
    await context.read<GetReviewsAdminProvider>().refresh(token);
  }

  Future<void> _openFilterSheet() async {
    final salonsProv = context.read<GetSalonsProvider>();
    final reviewsProv = context.read<GetReviewsAdminProvider>();
    final salons = salonsProv.getSalonsResponse ?? [];
    await showAdminReviewsFilterSheet(
      context,
      initialDraft: reviewsProv.activeFilter,
      salons: salons,
      onApply: (applied) {
        reviewsProv.setActiveFilter(applied);
        final salon = applied.salonId;
        if (salon != null && salon.isNotEmpty) {
          AdminLastSalonStorage.write(salon);
        }
        _reloadList();
      },
      onResetAll: () {
        reviewsProv.setActiveFilter(ReviewAdminFilter.empty);
        _reloadList();
      },
    );
    if (mounted) setState(() {});
  }

  Future<void> _resetFiltersQuick() async {
    context.read<GetReviewsAdminProvider>().setActiveFilter(ReviewAdminFilter.empty);
    await _reloadList();
    if (mounted) setState(() {});
  }

  Future<void> _exportToExcel() async {
    final token = context.read<AuthProvider>().token;
    final filter = context.read<GetReviewsAdminProvider>().activeFilter;
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const Center(child: CircularProgressIndicator()),
    );
    try {
      final rows = await GetReviewsAdminService().fetchAllPages(
        filter,
        token,
      );
      if (!mounted) return;
      Navigator.of(context).pop();
      if (rows.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Нет данных для экспорта')),
        );
        return;
      }
      final stamp = DateFormat('yyyyMMdd_HHmm').format(DateTime.now());
      await AdminExcelExportService.instance.shareReviews(
        rows,
        'отзывы_$stamp',
      );
    } catch (_) {
      if (mounted) Navigator.of(context).pop();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Не удалось экспортировать')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final df = DateFormat('dd.MM.yyyy HH:mm');
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.initialSalonId != null ? 'Отзывы салона' : 'Отзывы',
        ),
        automaticallyImplyLeading: widget.initialSalonId != null,
        actions: [
          IconButton(
            tooltip: 'Экспорт Excel',
            onPressed: _exportToExcel,
            icon: const Icon(Icons.table_chart_outlined),
          ),
        ],
      ),
      body: Column(
        children: [
          Consumer2<GetSalonsProvider, GetReviewsAdminProvider>(
            builder: (context, salonsProv, reviewsProv, _) {
              final salons = salonsProv.getSalonsResponse ?? [];
              return AdminReviewsFilterSummaryBar(
                applied: reviewsProv.activeFilter,
                salons: salons,
                onOpenSheet: _openFilterSheet,
                onReset: reviewsProv.activeFilter.activeCount > 0
                    ? _resetFiltersQuick
                    : null,
              );
            },
          ),
          Divider(height: 1, color: cs.outline.withValues(alpha: 0.15)),
          Expanded(
            child: Consumer<GetReviewsAdminProvider>(
              builder: (context, prov, _) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (prov.errorMessage != null && mounted) {
                    prov.showApiError(context, prov.errorMessage);
                  }
                });

                if (prov.isLoading && prov.items.isEmpty) {
                  return const Center(
                    child: LoadingIndicator(message: 'Загрузка отзывов...'),
                  );
                }

                if (prov.errorMessage != null && prov.items.isEmpty) {
                  return Center(
                    child: ErrorWidgetCustom(
                      message: prov.errorMessage!,
                      onRetry: _reloadList,
                    ),
                  );
                }

                if (prov.items.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.reviews_outlined,
                          size: 56,
                          color: cs.onSurfaceVariant.withValues(alpha: 0.45),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Нет отзывов по выбранным условиям',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Откройте фильтры и настройте поиск',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: cs.onSurfaceVariant),
                        ),
                      ],
                    ),
                  );
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                      child: Text(
                        'Найдено: ${prov.serverCount}',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              color: cs.onSurfaceVariant,
                            ),
                      ),
                    ),
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: _reloadList,
                        child: ListView.builder(
                          padding: const EdgeInsets.fromLTRB(12, 0, 12, 24),
                          itemCount: prov.items.length + (prov.hasMore ? 1 : 0),
                          itemBuilder: (context, i) {
                            if (i >= prov.items.length) {
                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                child: Center(
                                  child: prov.isLoading
                                      ? const CircularProgressIndicator()
                                      : FilledButton.tonal(
                                          onPressed: () async {
                                            final t = context
                                                .read<AuthProvider>()
                                                .token;
                                            await prov.loadMore(t);
                                          },
                                          child: const Text('Загрузить ещё'),
                                        ),
                                ),
                              );
                            }
                            final r = prov.items[i];
                            final salon =
                                r.dtoSalonNavigation?.SalonName ?? '—';
                            final master =
                                r.masterProfileNavigation?.MasterName ?? '—';
                            final service =
                                r.dtoAppointmentNavigation?.ServiceName ?? '';

                            return Card(
                              margin: const EdgeInsets.only(bottom: 10),
                              elevation: 0,
                              color: cs.surfaceContainerHighest.withValues(
                                alpha: 0.45,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                                side: BorderSide(
                                  color: cs.outline.withValues(alpha: 0.12),
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(14),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        CircleAvatar(
                                          radius: 22,
                                          backgroundColor:
                                              cs.primaryContainer,
                                          child: Text(
                                            _clientInitial(r.ClientName),
                                            style: TextStyle(
                                              color: cs.onPrimaryContainer,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                r.ClientName ?? '—',
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: 16,
                                                ),
                                              ),
                                              if (r.CreatedAt != null)
                                                Text(
                                                  df.format(
                                                    r.CreatedAt!.toLocal(),
                                                  ),
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color:
                                                        cs.onSurfaceVariant,
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                        _RatingPill(
                                          label: 'Салон',
                                          value: r.SalonRating,
                                        ),
                                        const SizedBox(width: 6),
                                        _RatingPill(
                                          label: 'Мастер',
                                          value: r.MasterRating,
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    _InfoLine(
                                      icon: Icons.store_mall_directory_outlined,
                                      text: salon,
                                    ),
                                    _InfoLine(
                                      icon: Icons.person_outline_rounded,
                                      text: master,
                                    ),
                                    if (service.isNotEmpty)
                                      _InfoLine(
                                        icon: Icons.content_cut_rounded,
                                        text: service,
                                      ),
                                    if (r.Comment != null &&
                                        r.Comment!.trim().isNotEmpty) ...[
                                      const SizedBox(height: 10),
                                      Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: cs.surface,
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: Text(
                                          r.Comment!.trim(),
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

String _clientInitial(String? name) {
  final s = (name ?? '?').trim();
  if (s.isEmpty) return '?';
  return s[0].toUpperCase();
}

class _RatingPill extends StatelessWidget {
  const _RatingPill({required this.label, required this.value});

  final String label;
  final int? value;
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final v = value;
    final text = v != null ? '$v★' : '—';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: cs.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 2),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: cs.secondaryContainer,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            text,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: cs.onSecondaryContainer,
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }
}

class _InfoLine extends StatelessWidget {
  const _InfoLine({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: cs.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}
