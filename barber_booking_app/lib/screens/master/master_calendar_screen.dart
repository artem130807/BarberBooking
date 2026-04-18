import 'package:barber_booking_app/models/master_interface_models/master_appointment_query_filter.dart';
import 'package:barber_booking_app/models/master_interface_models/response/get_master_appointments_short_response.dart';
import 'package:barber_booking_app/providers/auth_providers/auth_provider.dart';
import 'package:barber_booking_app/screens/master/master_appointment_detail_screen.dart';
import 'package:barber_booking_app/screens/master/master_navigation.dart';
import 'package:barber_booking_app/services/master_services/master_appointments_list_service.dart';
import 'package:barber_booking_app/utils/appointment_time_format.dart';
import 'package:barber_booking_app/utils/master_calendar_helpers.dart';
import 'package:barber_booking_app/widgets/loading_indicator.dart';
import 'package:barber_booking_app/widgets/master/master_notification_app_bar_button.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class MasterCalendarScreen extends StatefulWidget {
  const MasterCalendarScreen({
    super.key,
    this.masterNavTab = MasterNav.appointments,
  });

  /// С какой вкладки «Сегодня» / «Записи» открыт календарь.
  final int masterNavTab;

  @override
  State<MasterCalendarScreen> createState() => _MasterCalendarScreenState();
}

class _MasterCalendarScreenState extends State<MasterCalendarScreen>
    with SingleTickerProviderStateMixin {
  final MasterAppointmentsListService _service = MasterAppointmentsListService();
  late TabController _tab;
  List<GetMasterAppointmentsShortResponse> _items = [];
  bool _loading = true;

  late DateTime _weekMonday;
  late DateTime _monthPage;
  DateTime? _selectedDayInMonth;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
    final now = DateTime.now();
    _weekMonday = mondayOfWeekContaining(now);
    _monthPage = DateTime(now.year, now.month, 1);
    _selectedDayInMonth = dateOnly(now);
    _tab.addListener(_onTabChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  void _onTabChanged() {
    if (_tab.indexIsChanging) return;
    _load();
  }

  @override
  void dispose() {
    _tab.removeListener(_onTabChanged);
    _tab.dispose();
    super.dispose();
  }

  bool get _isWeekMode => _tab.index == 0;

  Future<void> _load() async {
    final token = context.read<AuthProvider>().token;
    setState(() => _loading = true);

    late DateTime fromD;
    late DateTime toD;
    if (_isWeekMode) {
      fromD = dateOnly(_weekMonday);
      toD = dateOnly(_weekMonday.add(const Duration(days: 6)));
    } else {
      fromD = DateTime(_monthPage.year, _monthPage.month, 1);
      toD = DateTime(_monthPage.year, _monthPage.month + 1, 0);
    }

    final page = await _service.fetchPage(
      filter: MasterAppointmentQueryFilter(
        appointmentFrom: fromD,
        appointmentTo: toD,
      ),
      pageSize: 500,
    );

    if (!mounted) return;
    final list = List<GetMasterAppointmentsShortResponse>.from(page?.data ?? []);
    list.sort((a, b) {
      final da = parseAppointmentDate(a.AppointmentDate);
      final db = parseAppointmentDate(b.AppointmentDate);
      if (da != null && db != null) {
        final c = da.compareTo(db);
        if (c != 0) return c;
      }
      return (a.StartTime ?? '').compareTo(b.StartTime ?? '');
    });

    setState(() {
      _items = list;
      _loading = false;
      if (!_isWeekMode) {
        _ensureSelectedDayInMonth();
      }
    });
  }

  void _ensureSelectedDayInMonth() {
    final first = DateTime(_monthPage.year, _monthPage.month, 1);
    final last = DateTime(_monthPage.year, _monthPage.month + 1, 0);
    final sel = _selectedDayInMonth ?? dateOnly(DateTime.now());
    if (sel.isBefore(first) || sel.isAfter(last)) {
      _selectedDayInMonth = first;
    } else {
      _selectedDayInMonth = dateOnly(sel);
    }
  }

  void _shiftWeek(int deltaWeeks) {
    setState(() {
      _weekMonday = _weekMonday.add(Duration(days: 7 * deltaWeeks));
    });
    _load();
  }

  void _shiftMonth(int delta) {
    setState(() {
      _monthPage = DateTime(_monthPage.year, _monthPage.month + delta, 1);
    });
    _load();
  }

  String _statusRu(String? s) {
    switch (s) {
      case 'Confirmed':
        return 'Подтверждена';
      case 'Completed':
        return 'Завершена';
      case 'Cancelled':
        return 'Отменена';
      default:
        return s ?? '—';
    }
  }

  Map<DateTime, List<GetMasterAppointmentsShortResponse>> _byDay() {
    final map = <DateTime, List<GetMasterAppointmentsShortResponse>>{};
    for (final a in _items) {
      final d = parseAppointmentDate(a.AppointmentDate);
      if (d == null) continue;
      final key = dateOnly(d);
      map.putIfAbsent(key, () => []).add(a);
    }
    for (final e in map.entries) {
      e.value.sort(
        (a, b) => (a.StartTime ?? '').compareTo(b.StartTime ?? ''),
      );
    }
    return map;
  }

  int _countForDay(DateTime day) {
    return _byDay()[dateOnly(day)]?.length ?? 0;
  }

  List<GetMasterAppointmentsShortResponse> _itemsForSelectedMonthDay() {
    final sel = _selectedDayInMonth;
    if (sel == null) return [];
    return _byDay()[dateOnly(sel)] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    final bg = Theme.of(context).scaffoldBackgroundColor;
    return MasterScreenScaffold(
      selectedTabIndex: widget.masterNavTab,
      backgroundColor: bg,
      appBar: AppBar(
        title: const Text('Календарь'),
        actions: const [MasterNotificationAppBarButton()],
        bottom: TabBar(
          controller: _tab,
          tabs: const [
            Tab(text: 'Неделя'),
            Tab(text: 'Месяц'),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: _loading
                ? const Center(
                    child: LoadingIndicator(message: 'Загрузка…'),
                  )
                : ColoredBox(
                    color: bg,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 220),
                      switchInCurve: Curves.easeOut,
                      switchOutCurve: Curves.easeOut,
                      child: _tab.index == 0
                          ? KeyedSubtree(
                              key: const ValueKey('cal_week'),
                              child: _WeekView(
                                weekMonday: _weekMonday,
                                byDay: _byDay(),
                                onPrevWeek: () => _shiftWeek(-1),
                                onNextWeek: () => _shiftWeek(1),
                                statusRu: _statusRu,
                                onOpenAppointment: _openAppointment,
                              ),
                            )
                          : KeyedSubtree(
                              key: const ValueKey('cal_month'),
                              child: _MonthView(
                                monthPage: _monthPage,
                                selectedDay: _selectedDayInMonth,
                                onSelectDay: (d) {
                                  setState(
                                    () => _selectedDayInMonth = dateOnly(d),
                                  );
                                },
                                onPrevMonth: () => _shiftMonth(-1),
                                onNextMonth: () => _shiftMonth(1),
                                countForDay: _countForDay,
                                itemsForDay: _itemsForSelectedMonthDay(),
                                statusRu: _statusRu,
                                onOpenAppointment: _openAppointment,
                              ),
                            ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Future<void> _openAppointment(String id) async {
    final refreshed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => MasterAppointmentDetailScreen(
              appointmentId: id,
              masterNavTab: widget.masterNavTab,
            ),
      ),
    );
    if (refreshed == true && mounted) {
      _load();
    }
  }
}

class _WeekView extends StatelessWidget {
  const _WeekView({
    required this.weekMonday,
    required this.byDay,
    required this.onPrevWeek,
    required this.onNextWeek,
    required this.statusRu,
    required this.onOpenAppointment,
  });

  final DateTime weekMonday;
  final Map<DateTime, List<GetMasterAppointmentsShortResponse>> byDay;
  final VoidCallback onPrevWeek;
  final VoidCallback onNextWeek;
  final String Function(String?) statusRu;
  final Future<void> Function(String id) onOpenAppointment;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final sunday = weekMonday.add(const Duration(days: 6));
    final rangeLabel =
        '${DateFormat('dd.MM').format(weekMonday)} – ${DateFormat('dd.MM.yyyy').format(sunday)}';

    final days = List.generate(7, (i) => dateOnly(weekMonday.add(Duration(days: i))));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Row(
            children: [
              _RoundNavIcon(
                icon: Icons.chevron_left_rounded,
                onTap: onPrevWeek,
              ),
              Expanded(
                child: Column(
                  children: [
                    Text(
                      rangeLabel,
                      textAlign: TextAlign.center,
                      style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Ниже — все записи этой недели по дням (пн → вс)',
                      textAlign: TextAlign.center,
                      style: tt.bodySmall?.copyWith(
                        color: cs.onSurfaceVariant,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              _RoundNavIcon(
                icon: Icons.chevron_right_rounded,
                onTap: onNextWeek,
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 24),
            itemCount: 7,
            itemBuilder: (context, i) {
              final day = days[i];
              final list = byDay[day] ?? [];
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${kWeekdayShortRu[i]} · ${DateFormat('dd.MM.yyyy').format(day)}',
                            style: tt.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: cs.onSurface,
                            ),
                          ),
                        ),
                        if (dateOnly(day) == dateOnly(DateTime.now()))
                          Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: Text(
                              'Сегодня',
                              style: tt.labelSmall?.copyWith(
                                color: cs.primary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: cs.primaryContainer.withValues(alpha: 0.65),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            appointmentCountRu(list.length),
                            style: tt.labelSmall?.copyWith(
                              color: cs.onPrimaryContainer,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ...list.map(
                      (a) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: _AppointmentCard(
                          a: a,
                          statusRu: statusRu,
                          onTap: a.Id == null || a.Id!.isEmpty
                              ? null
                              : () => onOpenAppointment(a.Id!),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _MonthView extends StatelessWidget {
  const _MonthView({
    required this.monthPage,
    required this.selectedDay,
    required this.onSelectDay,
    required this.onPrevMonth,
    required this.onNextMonth,
    required this.countForDay,
    required this.itemsForDay,
    required this.statusRu,
    required this.onOpenAppointment,
  });

  final DateTime monthPage;
  final DateTime? selectedDay;
  final ValueChanged<DateTime> onSelectDay;
  final VoidCallback onPrevMonth;
  final VoidCallback onNextMonth;
  final int Function(DateTime day) countForDay;
  final List<GetMasterAppointmentsShortResponse> itemsForDay;
  final String Function(String?) statusRu;
  final Future<void> Function(String id) onOpenAppointment;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final title =
        '${kMonthNamesRu[monthPage.month - 1]} ${monthPage.year}';

    final gridStart = firstGridDayForMonthPage(monthPage);
    final cells = List.generate(42, (i) => gridStart.add(Duration(days: i)));

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
            child: Row(
              children: [
                _RoundNavIcon(
                  icon: Icons.chevron_left_rounded,
                  onTap: onPrevMonth,
                ),
                Expanded(
                  child: Text(
                    title,
                    textAlign: TextAlign.center,
                    style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
                _RoundNavIcon(
                  icon: Icons.chevron_right_rounded,
                  onTap: onNextMonth,
                ),
              ],
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          sliver: SliverToBoxAdapter(
            child: Row(
              children: [
                for (final w in kWeekdayShortRu)
                  Expanded(
                    child: Center(
                      child: Text(
                        w,
                        style: tt.labelSmall?.copyWith(
                          color: cs.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 4)),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          sliver: SliverToBoxAdapter(
            child: Text(
              'Нажмите на число — ниже появятся записи на этот день. Серые ячейки — дни другого месяца.',
              style: tt.bodySmall?.copyWith(
                color: cs.onSurfaceVariant,
                height: 1.4,
              ),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 6,
              crossAxisSpacing: 6,
              childAspectRatio: 1.18,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, i) {
                final d = cells[i];
                final inMonth = d.month == monthPage.month;
                final sel = selectedDay != null &&
                    dateOnly(d) == dateOnly(selectedDay!);
                final today = dateOnly(d) == dateOnly(DateTime.now());
                final c = countForDay(d);

                return Material(
                  color: Colors.transparent,
                  clipBehavior: Clip.hardEdge,
                  child: InkWell(
                    onTap: inMonth ? () => onSelectDay(d) : null,
                    borderRadius: BorderRadius.circular(10),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: sel
                              ? cs.primary
                              : today
                                  ? cs.primary.withValues(alpha: 0.45)
                                  : cs.outline.withValues(alpha: 0.25),
                          width: sel ? 2 : 1,
                        ),
                        color: sel
                            ? cs.primary.withValues(alpha: 0.22)
                            : inMonth
                                ? cs.surfaceContainerHighest
                                    .withValues(alpha: 0.55)
                                : cs.surfaceContainerHighest
                                    .withValues(alpha: 0.15),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 2,
                          vertical: 2,
                        ),
                        child: Center(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  '${d.day}',
                                  style: tt.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    color: inMonth
                                        ? cs.onSurface
                                        : cs.onSurfaceVariant
                                            .withValues(alpha: 0.45),
                                  ),
                                ),
                                if (inMonth && c > 0)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 2),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 5,
                                        vertical: 1,
                                      ),
                                      decoration: BoxDecoration(
                                        color: cs.primary.withValues(alpha: 0.4),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        '$c',
                                        style: tt.labelSmall?.copyWith(
                                          color: cs.onPrimary,
                                          fontWeight: FontWeight.w800,
                                          fontSize: 10,
                                          height: 1.1,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
              childCount: 42,
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Записи на выбранный день',
                  style: tt.labelMedium?.copyWith(
                    color: cs.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.event_available_rounded, size: 22, color: cs.primary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        selectedDay == null
                            ? 'Выберите день в календаре выше'
                            : DateFormat('dd.MM.yyyy').format(selectedDay!),
                        style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        if (itemsForDay.isEmpty)
          SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'На этот день записей нет',
                  textAlign: TextAlign.center,
                  style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
                ),
              ),
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 24),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, i) {
                  final a = itemsForDay[i];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _AppointmentCard(
                      a: a,
                      statusRu: statusRu,
                      onTap: a.Id == null || a.Id!.isEmpty
                          ? null
                          : () => onOpenAppointment(a.Id!),
                    ),
                  );
                },
                childCount: itemsForDay.length,
              ),
            ),
          ),
      ],
    );
  }
}

class _AppointmentCard extends StatelessWidget {
  const _AppointmentCard({
    required this.a,
    required this.statusRu,
    required this.onTap,
  });

  final GetMasterAppointmentsShortResponse a;
  final String Function(String?) statusRu;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: cs.outline.withValues(alpha: 0.25)),
            color: cs.surfaceContainerHighest.withValues(alpha: 0.55),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 4,
                  height: 48,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color: cs.primary.withValues(alpha: 0.85),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        a.UserName ?? 'Клиент',
                        style: tt.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${formatAppointmentTimeHm(a.StartTime)}–${formatAppointmentTimeHm(a.EndTime)} · ${a.ServiceName ?? '—'}',
                        style: tt.bodySmall?.copyWith(
                          color: cs.onSurfaceVariant,
                          height: 1.35,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Chip(
                          visualDensity: VisualDensity.compact,
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                          padding: EdgeInsets.zero,
                          label: Text(
                            statusRu(a.Status),
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (a.Price?.Value != null)
                  Text(
                    '${a.Price!.Value!.toStringAsFixed(0)} ₽',
                    style: tt.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: cs.primary,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RoundNavIcon extends StatelessWidget {
  const _RoundNavIcon({
    required this.icon,
    required this.onTap,
  });

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Material(
      color: cs.surfaceContainerHighest.withValues(alpha: 0.55),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Icon(icon, color: cs.primary),
        ),
      ),
    );
  }
}
