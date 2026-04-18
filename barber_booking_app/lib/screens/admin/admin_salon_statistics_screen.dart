import 'package:barber_booking_app/models/salon_models/response/salon_stats_dto.dart';
import 'package:barber_booking_app/providers/auth_providers/auth_provider.dart';
import 'package:barber_booking_app/services/admin_export/admin_excel_export_service.dart';
import 'package:barber_booking_app/providers/salon_providers/salon_statistic_period_provider.dart';
import 'package:barber_booking_app/providers/salon_providers/salon_statistics_filter_provider.dart';
import 'package:barber_booking_app/widgets/loading_indicator.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

/// Без вызова [initializeDateFormatting] нельзя использовать DateFormat(..., 'ru_RU').
String _monthYearLabelRu(DateTime d) {
  const months = <String>[
    'январь',
    'февраль',
    'март',
    'апрель',
    'май',
    'июнь',
    'июль',
    'август',
    'сентябрь',
    'октябрь',
    'ноябрь',
    'декабрь',
  ];
  return '${months[d.month - 1]} ${d.year}';
}

class AdminSalonStatisticsScreen extends StatefulWidget {
  const AdminSalonStatisticsScreen({super.key, required this.salonId});

  final String salonId;

  @override
  State<AdminSalonStatisticsScreen> createState() =>
      _AdminSalonStatisticsScreenState();
}

class _AdminSalonStatisticsScreenState extends State<AdminSalonStatisticsScreen> {
  /// 0 — сводка (неделя/месяц/год), 1 — дневная статистика.
  int _viewSegment = 0;
  int _segment = 0;
  DateTime _weekAnchor = DateTime.now();
  DateTime _monthAnchor = DateTime(DateTime.now().year, DateTime.now().month, 1);
  int _year = DateTime.now().year;

  bool _feedUseDayFilter = false;
  int _feedDayOfMonth = DateTime.now().day;
  bool _feedAutoLoaded = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadInitial());
  }

  Future<void> _loadInitial() async {
    await context.read<SalonStatisticPeriodProvider>().loadWeek(
          widget.salonId,
          _weekAnchor,
        );
  }

  Future<void> _runLoad() async {
    final prov = context.read<SalonStatisticPeriodProvider>();
    switch (_segment) {
      case 0:
        await prov.loadWeek(widget.salonId, _weekAnchor);
        break;
      case 1:
        await prov.loadMonth(
          widget.salonId,
          _monthAnchor.year,
          _monthAnchor.month,
        );
        break;
      case 2:
        await prov.loadYear(widget.salonId, _year);
        break;
    }
    if (!mounted) return;
    final err = prov.errorMessage;
    if (err != null && err.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(err), behavior: SnackBarBehavior.floating),
      );
    }
  }

  Future<void> _loadFeed() async {
    final filterProv = context.read<SalonStatisticsFilterProvider>();
    await filterProv.load(
      salonId: widget.salonId,
      dayOfMonth: _feedUseDayFilter ? _feedDayOfMonth : null,
    );
    if (!mounted) return;
    final err = filterProv.errorMessage;
    if (err != null && err.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(err), behavior: SnackBarBehavior.floating),
      );
    }
  }

  Future<void> _exportToExcel() async {
    final stamp = DateFormat('yyyyMMdd_HHmm').format(DateTime.now());
    final base = 'статистика_салона_${widget.salonId}_$stamp';
    if (_viewSegment == 0) {
      final r = context.read<SalonStatisticPeriodProvider>().result;
      if (r == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Нет данных для экспорта')),
        );
        return;
      }
      String kind;
      String range;
      switch (_segment) {
        case 0:
          kind = 'Неделя';
          range = DateFormat('dd.MM.yyyy').format(_weekAnchor);
          break;
        case 1:
          kind = 'Месяц';
          range = _monthYearLabelRu(_monthAnchor);
          break;
        case 2:
          kind = 'Год';
          range = '$_year';
          break;
        default:
          kind = '';
          range = '';
      }
      await AdminExcelExportService.instance.shareSalonPeriodSummary(
        r,
        base,
        periodKindLabel: kind,
        periodRangeLabel: range,
      );
      return;
    }
    final items = context.read<SalonStatisticsFilterProvider>().items;
    if (items == null || items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Нет данных: сначала загрузите дневную статистику'),
        ),
      );
      return;
    }
    final filterDesc = _feedUseDayFilter
        ? 'День месяца: $_feedDayOfMonth'
        : 'Все дни месяца';
    await AdminExcelExportService.instance.shareSalonDailySnapshots(
      items,
      base,
      filterDescription: filterDesc,
    );
  }

  Future<void> _pickWeekDay() async {
    final d = await showDatePicker(
      context: context,
      initialDate: _weekAnchor,
      firstDate: DateTime(DateTime.now().year - 3),
      lastDate: DateTime(DateTime.now().year + 1, 12, 31),
      helpText: 'Выберите любой день нужной недели',
    );
    if (d != null) setState(() => _weekAnchor = d);
  }

  Future<void> _pickMonth() async {
    final d = await showDatePicker(
      context: context,
      initialDate: _monthAnchor,
      firstDate: DateTime(DateTime.now().year - 3),
      lastDate: DateTime(DateTime.now().year + 1, 12, 31),
      helpText: 'Выберите месяц',
    );
    if (d != null) {
      setState(() => _monthAnchor = DateTime(d.year, d.month, 1));
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final df = DateFormat('dd.MM.yyyy');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Статистика салона'),
        actions: [
          IconButton(
            tooltip: 'Экспорт Excel',
            onPressed: _exportToExcel,
            icon: const Icon(Icons.table_chart_outlined),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _SalonStyleToggleTile(
                    icon: Icons.summarize_outlined,
                    label: 'Сводка',
                    selected: _viewSegment == 0,
                    stacked: true,
                    onTap: () => setState(() => _viewSegment = 0),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _SalonStyleToggleTile(
                    icon: Icons.view_list_outlined,
                    label: 'Дневная статистика',
                    selected: _viewSegment == 1,
                    stacked: true,
                    onTap: () async {
                      setState(() => _viewSegment = 1);
                      if (!_feedAutoLoaded) {
                        _feedAutoLoaded = true;
                        await _loadFeed();
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _viewSegment == 0
                ? _buildSummaryTab(cs, df)
                : _buildFeedTab(cs),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryTab(
    ColorScheme cs,
    DateFormat df,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: Row(
            children: [
              Expanded(
                child: _SalonStyleToggleTile(
                  icon: Icons.date_range_outlined,
                  label: 'Неделя',
                  selected: _segment == 0,
                  dense: true,
                  onTap: () async {
                    setState(() => _segment = 0);
                    await _runLoad();
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _SalonStyleToggleTile(
                  icon: Icons.calendar_month_outlined,
                  label: 'Месяц',
                  selected: _segment == 1,
                  dense: true,
                  onTap: () async {
                    setState(() => _segment = 1);
                    await _runLoad();
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _SalonStyleToggleTile(
                  icon: Icons.calendar_today_outlined,
                  label: 'Год',
                  selected: _segment == 2,
                  dense: true,
                  onTap: () async {
                    setState(() => _segment = 2);
                    await _runLoad();
                  },
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: _segment == 0
              ? ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(Icons.event_outlined, color: cs.primary),
                  title: const Text('День внутри недели'),
                  subtitle: Text(df.format(_weekAnchor)),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () async {
                    await _pickWeekDay();
                    await _runLoad();
                  },
                )
              : _segment == 1
                  ? ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(Icons.calendar_month_outlined, color: cs.primary),
                      title: const Text('Месяц'),
                      subtitle: Text(_monthYearLabelRu(_monthAnchor)),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () async {
                        await _pickMonth();
                        await _runLoad();
                      },
                    )
                  : ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(Icons.today_outlined, color: cs.primary),
                      title: const Text('Год'),
                      subtitle: Text('$_year'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () async {
                        final y = await showDialog<int>(
                          context: context,
                          builder: (ctx) {
                            return AlertDialog(
                              title: const Text('Год'),
                              content: SizedBox(
                                width: 280,
                                height: 220,
                                child: YearPicker(
                                  firstDate: DateTime(DateTime.now().year - 5),
                                  lastDate: DateTime(DateTime.now().year + 2),
                                  selectedDate: DateTime(_year, 6, 1),
                                  onChanged: (d) => Navigator.pop(ctx, d.year),
                                ),
                              ),
                            );
                          },
                        );
                        if (y != null) {
                          setState(() => _year = y);
                          await _runLoad();
                        }
                      },
                    ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: FilledButton.icon(
            onPressed: _runLoad,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Обновить'),
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: Consumer<SalonStatisticPeriodProvider>(
            builder: (context, prov, _) {
              if (prov.isLoading && prov.result == null) {
                return const Center(
                  child: LoadingIndicator(message: 'Загрузка…'),
                );
              }
              final r = prov.result;
              if (r == null) {
                return Center(
                  child: Text(
                    'Нет данных',
                    style: TextStyle(color: cs.onSurfaceVariant),
                  ),
                );
              }
              final money = NumberFormat('#,##0.00', 'ru_RU');
              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Text(
                    'Итого за период',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _hintForSegment(_segment),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _MetricCard(
                          icon: Icons.star_rounded,
                          label: 'Рейтинг (сумма)',
                          value: r.rating.toStringAsFixed(1),
                          sub: 'сумма оценок (шт.): ${r.ratingCount}',
                          color: cs.primaryContainer,
                          onColor: cs.onPrimaryContainer,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _MetricCard(
                          icon: Icons.check_circle_outline_rounded,
                          label: 'Завершено',
                          value: '${r.completedAppointmentsCount}',
                          sub: 'записей за период',
                          color: cs.secondaryContainer,
                          onColor: cs.onSecondaryContainer,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  _MetricCard(
                    icon: Icons.payments_outlined,
                    label: 'Выручка',
                    value: '${money.format(r.sumPrice)} ₽',
                    sub: 'по ценам услуг за период',
                    color: cs.surfaceContainerHighest,
                    onColor: cs.onSurface,
                    fullWidth: true,
                  ),
                  const SizedBox(height: 10),
                  _MetricCard(
                    icon: Icons.cancel_outlined,
                    label: 'Отменено',
                    value: '${r.cancelledAppointmentsCount}',
                    sub: 'записей за период',
                    color: cs.tertiaryContainer,
                    onColor: cs.onTertiaryContainer,
                    fullWidth: true,
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFeedTab(ColorScheme cs) {
    final dfFull = DateFormat('dd.MM.yyyy HH:mm');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SwitchListTile(
          title: const Text('Фильтр по дню месяца'),
          subtitle: Text(
            _feedUseDayFilter
                ? 'Показывать только снимки, где день месяца = $_feedDayOfMonth'
                : 'Показать все снимки по салону',
            style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
          ),
          value: _feedUseDayFilter,
          onChanged: (v) => setState(() => _feedUseDayFilter = v),
        ),
        if (_feedUseDayFilter)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                const Text('День:'),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButton<int>(
                    isExpanded: true,
                    value: _feedDayOfMonth,
                    items: List.generate(
                      31,
                      (i) => DropdownMenuItem(value: i + 1, child: Text('${i + 1}')),
                    ),
                    onChanged: (v) {
                      if (v != null) setState(() => _feedDayOfMonth = v);
                    },
                  ),
                ),
              ],
            ),
          ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: FilledButton.icon(
            onPressed: _loadFeed,
            icon: const Icon(Icons.cloud_download_outlined),
            label: const Text('Загрузить'),
          ),
        ),
        Expanded(
          child: Consumer<SalonStatisticsFilterProvider>(
            builder: (context, prov, _) {
              if (prov.isLoading && prov.items == null) {
                return const Center(child: LoadingIndicator(message: 'Загрузка…'));
              }
              final items = prov.items;
              if (items == null || items.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      items == null
                          ? 'Нажмите «Загрузить» или переключитесь на эту вкладку ещё раз.'
                          : 'Нет записей за выбранные условия.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: cs.onSurfaceVariant),
                    ),
                  ),
                );
              }
              return RefreshIndicator(
                onRefresh: _loadFeed,
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, i) {
                    final row = items[i];
                    return _FeedSnapshotCard(row: row, dfFull: dfFull, cs: cs);
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  String _hintForSegment(int s) {
    switch (s) {
      case 0:
        return 'Календарная неделя (пн–вс) по UTC для выбранной даты. '
            'Показатели — сумма по всем дневным снимкам за эту неделю.';
      case 1:
        return 'Показатели — сумма по дневным снимкам за выбранный месяц.';
      case 2:
        return 'Показатели — сумма по дневным снимкам за выбранный год.';
      default:
        return '';
    }
  }
}

/// Те же отступы и карточка, что у `_MetricTile` на экране салона (Card + обводка).
class _SalonStyleToggleTile extends StatelessWidget {
  const _SalonStyleToggleTile({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
    this.dense = false,
    this.stacked = false,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final bool dense;
  /// Вертикально: иконка сверху, подпись снизу (длинные подписи).
  final bool stacked;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final vPad = dense ? 8.0 : (stacked ? 12.0 : 10.0);
    final iconSize = dense ? 18.0 : 22.0;

    Widget content;
    if (stacked) {
      content = Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: cs.primary, size: iconSize),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      );
    } else {
      content = Row(
        children: [
          Icon(icon, color: cs.primary, size: iconSize),
          SizedBox(width: dense ? 6 : 8),
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    fontSize: dense ? 13 : null,
                  ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      );
    }

    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      color: selected
          ? cs.primaryContainer.withValues(alpha: 0.35)
          : cs.surfaceContainerHighest.withValues(alpha: 0.4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: selected
              ? cs.primary.withValues(alpha: 0.55)
              : cs.outline.withValues(alpha: 0.12),
          width: selected ? 1.5 : 1,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: stacked ? 10 : 10, vertical: vPad),
          child: content,
        ),
      ),
    );
  }
}

class _FeedSnapshotCard extends StatelessWidget {
  const _FeedSnapshotCard({
    required this.row,
    required this.dfFull,
    required this.cs,
  });

  final SalonStatsDto row;
  final DateFormat dfFull;
  final ColorScheme cs;

  @override
  Widget build(BuildContext context) {
    final money = NumberFormat('#,##0.00', 'ru_RU');
    return Card(
      elevation: 0,
      color: cs.surfaceContainerHighest.withValues(alpha: 0.6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.schedule, size: 18, color: cs.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    dfFull.format(row.createdAt),
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: [
                _Chip(text: '★ ${row.rating.toStringAsFixed(1)}'),
                _Chip(text: 'оценок: ${row.ratingCount}'),
                _Chip(text: '✓ ${row.completedAppointmentsCount}'),
                _Chip(text: '✕ ${row.cancelledAppointmentsCount}'),
                _Chip(text: '₽ ${money.format(row.sumPrice)}'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(text, style: Theme.of(context).textTheme.labelMedium),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.sub,
    required this.color,
    required this.onColor,
    this.fullWidth = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final String sub;
  final Color color;
  final Color onColor;
  final bool fullWidth;

  @override
  Widget build(BuildContext context) {
    final card = Card(
      elevation: 0,
      color: color.withValues(alpha: 0.9),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: onColor, size: 22),
            const SizedBox(height: 8),
            Text(
              label,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: onColor.withValues(alpha: 0.85),
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: onColor,
                  ),
            ),
            Text(
              sub,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: onColor.withValues(alpha: 0.8),
                  ),
            ),
          ],
        ),
      ),
    );
    if (fullWidth) return card;
    return card;
  }
}
