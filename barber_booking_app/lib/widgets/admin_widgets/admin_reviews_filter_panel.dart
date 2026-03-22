import 'package:barber_booking_app/models/master_models/response/get_masters_response.dart';
import 'package:barber_booking_app/models/params/master_params/master_filter.dart';
import 'package:barber_booking_app/models/params/review_params/review_admin_filter.dart';
import 'package:barber_booking_app/models/salon_models/response/get_salons_response.dart';
import 'package:barber_booking_app/providers/master_providers/get_masters_provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

String _appliedFilterSubtitle(
  ReviewAdminFilter f,
  List<GetSalonsResponse> salons,
) {
  if (f.activeCount == 0) return 'Без ограничений';
  final parts = <String>[];
  if (f.salonId != null && f.salonId!.isNotEmpty) {
    var label = 'Салон';
    for (final e in salons) {
      if (e.Id == f.salonId) {
        label = e.Name ?? label;
        break;
      }
    }
    parts.add(label);
  }
  if (f.masterId != null && f.masterId!.isNotEmpty) parts.add('Мастер');
  if (f.from != null && f.to != null) parts.add('Период');
  if (f.prioritizeLowRatings) parts.add('Низкие первые');
  return parts.join(' · ');
}

class AdminReviewsFilterSummaryBar extends StatelessWidget {
  const AdminReviewsFilterSummaryBar({
    super.key,
    required this.applied,
    required this.salons,
    required this.onOpenSheet,
    this.onReset,
  });

  final ReviewAdminFilter applied;
  final List<GetSalonsResponse> salons;
  final VoidCallback onOpenSheet;
  final VoidCallback? onReset;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final n = applied.activeCount;
    return Material(
      color: cs.surfaceContainerHighest.withValues(alpha: 0.5),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: onOpenSheet,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  children: [
                    Icon(Icons.tune_rounded, size: 22, color: cs.primary),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Фильтры',
                            style:
                                Theme.of(context).textTheme.titleSmall?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                          ),
                          Text(
                            _appliedFilterSubtitle(applied, salons),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: cs.onSurfaceVariant,
                                ),
                          ),
                        ],
                      ),
                    ),
                    if (n > 0)
                      Padding(
                        padding: const EdgeInsets.only(right: 4),
                        child: Badge(
                          label: Text('$n'),
                          child: const SizedBox(width: 20, height: 20),
                        ),
                      ),
                    Icon(Icons.keyboard_arrow_up_rounded,
                        color: cs.onSurfaceVariant),
                  ],
                ),
              ),
            ),
          ),
          if (onReset != null && n > 0)
            IconButton(
              onPressed: onReset,
              tooltip: 'Сбросить фильтры',
              icon: Icon(Icons.restart_alt_rounded, color: cs.primary),
            ),
        ],
      ),
    );
  }
}

Future<void> showAdminReviewsFilterSheet(
  BuildContext context, {
  required ReviewAdminFilter initialDraft,
  required List<GetSalonsResponse> salons,
  required void Function(ReviewAdminFilter applied) onApply,
  required VoidCallback onResetAll,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    builder: (ctx) {
      return Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(ctx).bottom,
        ),
        child: _AdminReviewsFilterModal(
          initialDraft: initialDraft,
          salons: salons,
          onApply: onApply,
          onResetAll: onResetAll,
        ),
      );
    },
  );
}

class _AdminReviewsFilterModal extends StatefulWidget {
  const _AdminReviewsFilterModal({
    required this.initialDraft,
    required this.salons,
    required this.onApply,
    required this.onResetAll,
  });

  final ReviewAdminFilter initialDraft;
  final List<GetSalonsResponse> salons;
  final void Function(ReviewAdminFilter applied) onApply;
  final VoidCallback onResetAll;

  @override
  State<_AdminReviewsFilterModal> createState() =>
      _AdminReviewsFilterModalState();
}

class _AdminReviewsFilterModalState extends State<_AdminReviewsFilterModal> {
  late ReviewAdminFilter _draft;
  List<GetMastersResponse> _masters = [];
  bool _mastersLoading = false;

  @override
  void initState() {
    super.initState();
    _draft = widget.initialDraft;
    final sid = _draft.salonId;
    if (sid != null && sid.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadMasters(sid);
      });
    }
  }

  Future<void> _loadMasters(String salonId) async {
    setState(() {
      _mastersLoading = true;
      _masters = [];
    });
    final ok = await context.read<GetMastersProvider>().loadMasters(
          salonId,
          MasterFilter(MaxRating: false, Popular: false),
        );
    if (!mounted) return;
    setState(() {
      _mastersLoading = false;
      _masters = ok
          ? (context.read<GetMastersProvider>().masters ?? [])
          : <GetMastersResponse>[];
    });
  }

  void _onSalonChanged(String? v) {
    if (v == null || v.isEmpty) {
      setState(() => _masters = []);
      return;
    }
    _loadMasters(v);
  }

  Future<void> _pickRange() async {
    final now = DateTime.now();
    final initial = _draft.from != null && _draft.to != null
        ? DateTimeRange(start: _draft.from!, end: _draft.to!)
        : null;
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 3),
      lastDate: DateTime(now.year + 1),
      initialDateRange: initial,
    );
    if (range == null || !mounted) return;
    setState(() {
      _draft = _draft.copyWith(
        from: DateTime(range.start.year, range.start.month, range.start.day),
        to: DateTime(
          range.end.year,
          range.end.month,
          range.end.day,
          23,
          59,
          59,
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final df = DateFormat('dd.MM.yyyy');
    final periodLabel = _draft.from != null && _draft.to != null
        ? '${df.format(_draft.from!)} — ${df.format(_draft.to!)}'
        : 'Любой период';
    final salonOk =
        widget.salons.where((e) => e.Id != null && e.Id!.isNotEmpty).toList();
    final masterOk =
        _masters.where((e) => e.Id != null && e.Id!.isNotEmpty).toList();
    final salonSelected = _draft.salonId != null &&
        salonOk.any((e) => e.Id == _draft.salonId);

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.72,
      minChildSize: 0.38,
      maxChildSize: 0.94,
      builder: (context, scrollController) {
        return DecoratedBox(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 8, 8),
                child: Row(
                  children: [
                    Text(
                      'Фильтры отзывов',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close_rounded),
                      tooltip: 'Закрыть',
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                  children: [
                    Text(
                      'Салон',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: cs.onSurfaceVariant,
                          ),
                    ),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String?>(
                      key: ValueKey('salon_${_draft.widgetKey}'),
                      value: salonSelected ? _draft.salonId : null,
                      isExpanded: true,
                      decoration: InputDecoration(
                        filled: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                      ),
                      hint: const Text('Все салоны'),
                      items: [
                        const DropdownMenuItem<String?>(
                          value: null,
                          child: Text('Все салоны'),
                        ),
                        ...salonOk.map(
                          (e) => DropdownMenuItem<String?>(
                            value: e.Id,
                            child: Text(
                              e.Name ?? '—',
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ],
                      onChanged: (v) {
                        setState(() {
                          if (v == null) {
                            _draft = _draft.copyWith(
                              clearSalon: true,
                              clearMaster: true,
                            );
                          } else {
                            _draft = _draft.copyWith(
                              salonId: v,
                              clearMaster: true,
                            );
                          }
                        });
                        _onSalonChanged(v);
                      },
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Мастер',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: cs.onSurfaceVariant,
                          ),
                    ),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String?>(
                      key: ValueKey('master_${_draft.widgetKey}'),
                      value: _draft.salonId != null &&
                              masterOk.any((e) => e.Id == _draft.masterId)
                          ? _draft.masterId
                          : null,
                      isExpanded: true,
                      decoration: InputDecoration(
                        filled: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                      ),
                      hint: Text(
                        _draft.salonId == null
                            ? 'Сначала выберите салон'
                            : 'Все мастера',
                      ),
                      items: [
                        const DropdownMenuItem<String?>(
                          value: null,
                          child: Text('Все мастера'),
                        ),
                        ...masterOk.map(
                          (e) => DropdownMenuItem<String?>(
                            value: e.Id,
                            child: Text(
                              e.UserName ?? e.Specialization ?? '—',
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ],
                      onChanged: _draft.salonId == null || _mastersLoading
                          ? null
                          : (v) {
                              setState(() {
                                if (v == null) {
                                  _draft = _draft.copyWith(clearMaster: true);
                                } else {
                                  _draft = _draft.copyWith(masterId: v);
                                }
                              });
                            },
                    ),
                    if (_mastersLoading)
                      const Padding(
                        padding: EdgeInsets.only(top: 8),
                        child: LinearProgressIndicator(minHeight: 2),
                      ),
                    const SizedBox(height: 12),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(Icons.date_range_rounded, color: cs.primary),
                      title: const Text('Период'),
                      subtitle: Text(periodLabel),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: _pickRange,
                    ),
                    if (_draft.from != null || _draft.to != null)
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () => setState(
                            () => _draft = _draft.copyWith(clearPeriod: true),
                          ),
                          child: const Text('Сбросить период'),
                        ),
                      ),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Сначала низкие оценки'),
                      subtitle: Text(
                        'По оценке салона и мастера',
                        style: TextStyle(
                          fontSize: 12,
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                      value: _draft.prioritizeLowRatings,
                      onChanged: (v) => setState(
                        () => _draft = _draft.copyWith(prioritizeLowRatings: v),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                child: SafeArea(
                  top: false,
                  child: Row(
                    children: [
                      Expanded(
                        child: FilledButton(
                          onPressed: () {
                            widget.onApply(_draft);
                            Navigator.of(context).pop();
                          },
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text('Применить'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _draft = ReviewAdminFilter.empty;
                            _masters = [];
                          });
                          widget.onResetAll();
                          Navigator.of(context).pop();
                        },
                        child: const Text('Сбросить'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
