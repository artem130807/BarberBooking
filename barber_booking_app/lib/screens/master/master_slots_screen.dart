import 'package:barber_booking_app/models/master_interface_models/response/get_master_time_slot_response.dart';
import 'package:barber_booking_app/screens/master/master_create_time_slot_screen.dart';
import 'package:barber_booking_app/screens/master/master_time_slot_detail_screen.dart';
import 'package:barber_booking_app/screens/master/master_weekly_templates_screen.dart';
import 'package:barber_booking_app/services/master_services/master_time_slots_service.dart';
import 'package:barber_booking_app/utils/appointment_time_format.dart';
import 'package:barber_booking_app/utils/slot_status_label.dart';
import 'package:barber_booking_app/widgets/loading_indicator.dart';
import 'package:barber_booking_app/widgets/master/master_notification_app_bar_button.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MasterSlotsScreen extends StatefulWidget {
  const MasterSlotsScreen({super.key, required this.masterId});

  final String masterId;

  @override
  State<MasterSlotsScreen> createState() => _MasterSlotsScreenState();
}

class _MasterSlotsScreenState extends State<MasterSlotsScreen> {
  final MasterTimeSlotsService _service = MasterTimeSlotsService();
  late DateTime _date;
  List<GetMasterTimeSlotResponse> _items = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    final n = DateTime.now();
    _date = DateTime(n.year, n.month, n.day);
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    if (widget.masterId.isEmpty) {
      if (mounted) setState(() => _loading = false);
      return;
    }
    setState(() => _loading = true);
    final list = await _service.fetchForDate(
      masterId: widget.masterId,
      date: _date,
    );
    if (!mounted) return;
    final raw = list ?? [];
    final visible = raw.where((s) => !s.isCancelled).toList()
      ..sort((a, b) {
        final sa = a.StartTime ?? '';
        final sb = b.StartTime ?? '';
        return sa.compareTo(sb);
      });
    setState(() {
      _items = visible;
      _loading = false;
    });
  }

  void _shiftDay(int delta) {
    setState(() {
      _date = _date.add(Duration(days: delta));
    });
    _load();
  }

  bool get _selectedDateIsBeforeToday {
    final n = DateTime.now();
    final today = DateTime(n.year, n.month, n.day);
    return _date.isBefore(today);
  }

  Future<void> _pickDate() async {
    final n = DateTime.now();
    final todayStart = DateTime(n.year, n.month, n.day);
    final picked = await showDatePicker(
      context: context,
      initialDate: _date.isBefore(todayStart) ? todayStart : _date,
      firstDate: todayStart,
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _date = DateTime(picked.year, picked.month, picked.day);
      });
      _load();
    }
  }

  Future<void> _openCreate() async {
    final refreshed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => MasterCreateTimeSlotScreen(initialDate: _date),
      ),
    );
    if (refreshed == true && mounted) _load();
  }

  Future<void> _openDetail(GetMasterTimeSlotResponse slot) async {
    final id = slot.Id;
    if (id == null || id.isEmpty) return;
    final refreshed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => MasterTimeSlotDetailScreen(slotId: id),
      ),
    );
    if (refreshed == true && mounted) _load();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final df = DateFormat('dd.MM.yyyy');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Слоты'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            tooltip: 'Недельные шаблоны',
            onPressed: widget.masterId.isEmpty
                ? null
                : () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const MasterWeeklyTemplatesScreen(),
                      ),
                    );
                  },
            icon: const Icon(Icons.view_week_outlined),
          ),
          const MasterNotificationAppBarButton(),
        ],
      ),
      floatingActionButton: widget.masterId.isEmpty
          ? null
          : Tooltip(
              message: _selectedDateIsBeforeToday
                  ? 'Нельзя создать слот на прошедшую дату'
                  : 'Новый слот',
              child: FloatingActionButton.extended(
                onPressed:
                    _selectedDateIsBeforeToday ? null : _openCreate,
                icon: const Icon(Icons.add),
                label: const Text('Новый слот'),
              ),
            ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: cs.outline.withValues(alpha: 0.2),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: _loading ? null : () => _shiftDay(-1),
                      icon: const Icon(Icons.chevron_left),
                    ),
                    Expanded(
                      child: InkWell(
                        onTap: _loading ? null : _pickDate,
                        borderRadius: BorderRadius.circular(8),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Column(
                            children: [
                              Text(
                                'Дата',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: cs.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                df.format(_date),
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(fontWeight: FontWeight.w700),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: _loading ? null : () => _shiftDay(1),
                      icon: const Icon(Icons.chevron_right),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: LoadingIndicator(message: 'Загрузка…'))
                : widget.masterId.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Text(
                            'Профиль мастера не загружен',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: cs.onSurfaceVariant),
                          ),
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _load,
                        child: _items.isEmpty
                            ? ListView(
                                physics: const AlwaysScrollableScrollPhysics(),
                                children: [
                                  SizedBox(
                                    height:
                                        MediaQuery.of(context).size.height * 0.45,
                                    child: Center(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.event_available_outlined,
                                            size: 56,
                                            color: cs.onSurfaceVariant
                                                .withValues(alpha: 0.45),
                                          ),
                                          const SizedBox(height: 12),
                                          Text(
                                            'Нет слотов на этот день',
                                            style: TextStyle(
                                              color: cs.onSurfaceVariant,
                                            ),
                                          ),
                                          const SizedBox(height: 16),
                                          FilledButton.tonal(
                                            onPressed: _selectedDateIsBeforeToday
                                                ? null
                                                : _openCreate,
                                            child: const Text('Создать слот'),
                                          ),
                                          if (_selectedDateIsBeforeToday) ...[
                                            const SizedBox(height: 12),
                                            Text(
                                              'Создание слотов на прошедшие даты недоступно',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                fontSize: 13,
                                                color: cs.onSurfaceVariant,
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            : ListView.separated(
                                padding:
                                    const EdgeInsets.fromLTRB(16, 0, 16, 96),
                                itemCount: _items.length,
                                separatorBuilder: (_, __) =>
                                    const SizedBox(height: 10),
                                itemBuilder: (context, i) {
                                  final s = _items[i];
                                  final timeRange =
                                      '${formatAppointmentTimeHm(s.StartTime)} – '
                                      '${formatAppointmentTimeHm(s.EndTime)}';
                                  return Card(
                                    margin: EdgeInsets.zero,
                                    clipBehavior: Clip.antiAlias,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      side: BorderSide(
                                        color: cs.outline.withValues(alpha: 0.2),
                                      ),
                                    ),
                                    child: Material(
                                      color: Colors.transparent,
                                      child: InkWell(
                                        onTap: () => _openDetail(s),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 14,
                                          ),
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              DecoratedBox(
                                                decoration: BoxDecoration(
                                                  color: cs.primaryContainer,
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                                child: SizedBox(
                                                  width: 48,
                                                  height: 48,
                                                  child: Icon(
                                                    Icons.schedule_rounded,
                                                    color: cs.onPrimaryContainer,
                                                    size: 24,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 14),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      timeRange,
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .titleMedium
                                                          ?.copyWith(
                                                            fontWeight:
                                                                FontWeight.w700,
                                                            letterSpacing:
                                                                -0.2,
                                                          ),
                                                    ),
                                                    const SizedBox(height: 8),
                                                    Align(
                                                      alignment:
                                                          Alignment.centerLeft,
                                                      child: Chip(
                                                        visualDensity:
                                                            VisualDensity
                                                                .compact,
                                                        label: Text(
                                                          slotStatusLabelRu(
                                                              s.Status),
                                                          style:
                                                              const TextStyle(
                                                            fontSize: 12,
                                                          ),
                                                        ),
                                                        padding:
                                                            EdgeInsets.zero,
                                                        materialTapTargetSize:
                                                            MaterialTapTargetSize
                                                                .shrinkWrap,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Icon(
                                                Icons.chevron_right_rounded,
                                                color: cs.onSurfaceVariant
                                                    .withValues(alpha: 0.65),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ),
          ),
        ],
      ),
    );
  }
}
