import 'package:barber_booking_app/models/master_models/response/master_statistic_response.dart';
import 'package:barber_booking_app/screens/master/master_navigation.dart';
import 'package:barber_booking_app/providers/auth_providers/auth_provider.dart';
import 'package:barber_booking_app/services/master_services/master_statistics_service.dart';
import 'package:barber_booking_app/widgets/loading_indicator.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class MasterStatisticsScreen extends StatefulWidget {
  const MasterStatisticsScreen({super.key});

  @override
  State<MasterStatisticsScreen> createState() => _MasterStatisticsScreenState();
}

class _MasterStatisticsScreenState extends State<MasterStatisticsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreenScaffold(
      selectedTabIndex: MasterNav.profile,
      appBar: AppBar(
        title: const Text('Статистика'),
        bottom: TabBar(
          controller: _tab,
          onTap: (_) => setState(() {}),
          tabs: const [
            Tab(text: 'Неделя'),
            Tab(text: 'Месяц'),
            Tab(text: 'Год'),
          ],
        ),
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: _tab.index == 0
            ? const _WeekBody(key: ValueKey('w'))
            : _tab.index == 1
                ? const _MonthBody(key: ValueKey('m'))
                : const _YearBody(key: ValueKey('y')),
      ),
    );
  }
}

class _WeekBody extends StatefulWidget {
  const _WeekBody({super.key});

  @override
  State<_WeekBody> createState() => _WeekBodyState();
}

class _WeekBodyState extends State<_WeekBody> {
  final MasterStatisticsService _service = MasterStatisticsService();
  MasterStatisticResponse? _data;
  bool _loading = true;
  late DateTime _anchor;

  @override
  void initState() {
    super.initState();
    _anchor = DateTime.now();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    final token = context.read<AuthProvider>().token;
    setState(() => _loading = true);
    final r = await _service.fetchWeek(
      token: token,
      month: _anchor.month,
      week: 1,
      anchorDate: _anchor,
    );
    if (!mounted) return;
    setState(() {
      _data = r;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final df = DateFormat('dd.MM.yyyy');
    return _StatScroll(
      loading: _loading,
      data: _data,
      onRefresh: _load,
      subtitle: 'Неделя с понедельника относительно ${df.format(_anchor)}',
      cs: cs,
    );
  }
}

class _MonthBody extends StatefulWidget {
  const _MonthBody({super.key});

  @override
  State<_MonthBody> createState() => _MonthBodyState();
}

class _MonthBodyState extends State<_MonthBody> {
  final MasterStatisticsService _service = MasterStatisticsService();
  MasterStatisticResponse? _data;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    final token = context.read<AuthProvider>().token;
    final n = DateTime.now();
    setState(() => _loading = true);
    final r = await _service.fetchMonth(
      token: token,
      month: n.month,
      anchorDate: DateTime(n.year, n.month, 1),
    );
    if (!mounted) return;
    setState(() {
      _data = r;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return _StatScroll(
      loading: _loading,
      data: _data,
      onRefresh: _load,
      subtitle: 'Текущий календарный месяц',
      cs: cs,
    );
  }
}

class _YearBody extends StatefulWidget {
  const _YearBody({super.key});

  @override
  State<_YearBody> createState() => _YearBodyState();
}

class _YearBodyState extends State<_YearBody> {
  final MasterStatisticsService _service = MasterStatisticsService();
  MasterStatisticResponse? _data;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    final token = context.read<AuthProvider>().token;
    final n = DateTime.now();
    setState(() => _loading = true);
    final r = await _service.fetchYear(
      token: token,
      anchorDate: DateTime(n.year, 6, 15),
    );
    if (!mounted) return;
    setState(() {
      _data = r;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return _StatScroll(
      loading: _loading,
      data: _data,
      onRefresh: _load,
      subtitle: 'Текущий календарный год',
      cs: cs,
    );
  }
}

class _StatScroll extends StatelessWidget {
  const _StatScroll({
    required this.loading,
    required this.data,
    required this.onRefresh,
    required this.subtitle,
    required this.cs,
  });

  final bool loading;
  final MasterStatisticResponse? data;
  final Future<void> Function() onRefresh;
  final String subtitle;
  final ColorScheme cs;

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Center(child: LoadingIndicator(message: 'Загрузка…'));
    }
    if (data == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.analytics_outlined, size: 48, color: cs.onSurfaceVariant),
            const SizedBox(height: 12),
            Text(
              'Не удалось загрузить данные',
              style: TextStyle(color: cs.onSurfaceVariant),
            ),
            const SizedBox(height: 16),
            FilledButton.tonal(
              onPressed: () => onRefresh(),
              child: const Text('Повторить'),
            ),
          ],
        ),
      );
    }
    final d = data!;
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            subtitle,
            style: TextStyle(color: cs.onSurfaceVariant, fontSize: 13),
          ),
          const SizedBox(height: 20),
          _tile(
            cs,
            Icons.check_circle_outline,
            'Завершённые записи',
            '${d.completedAppointmentsCount ?? 0}',
          ),
          _tile(
            cs,
            Icons.cancel_outlined,
            'Отменённые записи',
            '${d.cancelledAppointmentsCount ?? 0}',
          ),
          _tile(
            cs,
            Icons.star_outline,
            'Сумма рейтингов',
            (d.rating ?? 0).toStringAsFixed(1),
          ),
          _tile(
            cs,
            Icons.rate_review_outlined,
            'Количество оценок',
            '${d.ratingCount ?? 0}',
          ),
          _tile(
            cs,
            Icons.payments_outlined,
            'Сумма услуг',
            '${(d.sumPrice ?? 0).toStringAsFixed(0)} ₽',
          ),
        ],
      ),
    );
  }

  Widget _tile(ColorScheme cs, IconData icon, String title, String value) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: cs.primary),
        title: Text(title),
        trailing: Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: cs.primary,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
