import 'package:barber_booking_app/models/master_interface_models/response/get_master_time_slot_response.dart';
import 'package:barber_booking_app/screens/master/master_navigation.dart';
import 'package:barber_booking_app/screens/master/master_slot_appointments_screen.dart';
import 'package:barber_booking_app/services/master_services/master_time_slots_service.dart';
import 'package:barber_booking_app/utils/appointment_time_format.dart';
import 'package:barber_booking_app/utils/slot_status_label.dart';
import 'package:barber_booking_app/widgets/loading_indicator.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MasterTimeSlotDetailScreen extends StatefulWidget {
  const MasterTimeSlotDetailScreen({super.key, required this.slotId});

  final String slotId;

  @override
  State<MasterTimeSlotDetailScreen> createState() =>
      _MasterTimeSlotDetailScreenState();
}

class _MasterTimeSlotDetailScreenState extends State<MasterTimeSlotDetailScreen> {
  final MasterTimeSlotsService _service = MasterTimeSlotsService();
  GetMasterTimeSlotResponse? _data;
  bool _loading = true;
  bool _deleting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final r = await _service.fetchById(slotId: widget.slotId);
    if (!mounted) return;
    setState(() {
      _data = r;
      _loading = false;
    });
  }

  String _dateLabel(String? raw) {
    if (raw == null || raw.isEmpty) return '—';
    final d = DateTime.tryParse(raw);
    if (d == null) return raw;
    return DateFormat('dd.MM.yyyy').format(d.toLocal());
  }

  String _slotSubtitle(GetMasterTimeSlotResponse d) {
    return '${formatAppointmentTimeHm(d.StartTime)}–'
        '${formatAppointmentTimeHm(d.EndTime)} · ${_dateLabel(d.ScheduleDate)}';
  }

  String _recordsWord(int n) {
    final m10 = n % 10;
    final m100 = n % 100;
    if (m100 >= 11 && m100 <= 14) return 'записей';
    if (m10 == 1) return 'запись';
    if (m10 >= 2 && m10 <= 4) return 'записи';
    return 'записей';
  }

  bool _canDelete(GetMasterTimeSlotResponse? d) =>
      d != null && !d.isCancelled;

  Future<void> _openAppointments(GetMasterTimeSlotResponse d) async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => MasterSlotAppointmentsScreen(
          timeSlotId: widget.slotId,
          slotTimeLabel: _slotSubtitle(d),
        ),
      ),
    );
    if (mounted) _load();
  }

  Future<void> _confirmDelete() async {
    final cs = Theme.of(context).colorScheme;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Удалить слот?'),
        content: const Text(
          'Все записи на этот слот будут автоматически отменены. Продолжить?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Нет'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(
              backgroundColor: cs.error,
              foregroundColor: cs.onError,
            ),
            child: const Text('Удалить слот'),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    setState(() => _deleting = true);
    final success = await _service.deleteSlot(
      slotId: widget.slotId,
    );
    if (!mounted) return;
    setState(() => _deleting = false);
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Слот удалён')),
      );
      Navigator.of(context).pop(true);
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Не удалось удалить слот')),
    );
  }

  RoundedRectangleBorder _cardShape(ColorScheme cs) {
    return RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
      side: BorderSide(color: cs.outline.withValues(alpha: 0.2)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return MasterScreenScaffold(
      selectedTabIndex: MasterNav.slots,
      appBar: AppBar(
        title: const Text('Слот'),
      ),
      body: _loading
          ? const Center(child: LoadingIndicator(message: 'Загрузка…'))
          : _data == null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Не удалось загрузить слот',
                        style: TextStyle(color: cs.onSurfaceVariant),
                      ),
                      const SizedBox(height: 16),
                      FilledButton.tonal(
                        onPressed: _load,
                        child: const Text('Повторить'),
                      ),
                    ],
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
                  children: [
                    Card(
                      margin: EdgeInsets.zero,
                      clipBehavior: Clip.antiAlias,
                      shape: _cardShape(cs),
                      child: Padding(
                        padding: const EdgeInsets.all(18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _DetailField(
                              label: 'Дата',
                              child: Text(
                                _dateLabel(_data!.ScheduleDate),
                                style: tt.bodyLarge?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const SizedBox(height: 18),
                            _DetailField(
                              label: 'Время',
                              child: Text(
                                '${formatAppointmentTimeHm(_data!.StartTime)} – '
                                '${formatAppointmentTimeHm(_data!.EndTime)}',
                                style: tt.bodyLarge?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const SizedBox(height: 18),
                            _DetailField(
                              label: 'Статус',
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Chip(
                                  label: Text(slotStatusLabelRu(_data!.Status)),
                                ),
                              ),
                            ),
                            const SizedBox(height: 18),
                            _DetailField(
                              label: 'Записей на слот',
                              child: Text(
                                '${_data!.TimeSlotCount ?? 0} '
                                '${_recordsWord(_data!.TimeSlotCount ?? 0)}',
                                style: tt.bodyLarge?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Card(
                      margin: EdgeInsets.zero,
                      clipBehavior: Clip.antiAlias,
                      shape: _cardShape(cs),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => _openAppointments(_data!),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            child: ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: cs.primaryContainer,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  Icons.people_outline_rounded,
                                  color: cs.onPrimaryContainer,
                                ),
                              ),
                              title: const Text(
                                'Все записи на этот слот',
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                              subtitle: Text(
                                'Открыть список',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: cs.onSurfaceVariant,
                                ),
                              ),
                              trailing: Icon(
                                Icons.chevron_right_rounded,
                                color: cs.onSurfaceVariant
                                    .withValues(alpha: 0.65),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    if (_canDelete(_data))
                      FilledButton(
                        onPressed: _deleting ? null : _confirmDelete,
                        style: FilledButton.styleFrom(
                          backgroundColor: cs.error,
                          foregroundColor: cs.onError,
                          disabledBackgroundColor:
                              cs.error.withValues(alpha: 0.38),
                          disabledForegroundColor:
                              cs.onError.withValues(alpha: 0.38),
                          padding: const EdgeInsets.symmetric(
                            vertical: 14,
                            horizontal: 24,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _deleting
                            ? SizedBox(
                                height: 22,
                                width: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: cs.onError,
                                ),
                              )
                            : const Text('Удалить слот'),
                      ),
                  ],
                ),
    );
  }
}

class _DetailField extends StatelessWidget {
  const _DetailField({
    required this.label,
    required this.child,
  });

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: cs.onSurfaceVariant,
            letterSpacing: 0.2,
          ),
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}
