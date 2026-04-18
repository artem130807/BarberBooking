import 'package:barber_booking_app/models/master_interface_models/request/create_time_slot_request.dart';
import 'package:barber_booking_app/screens/master/master_navigation.dart';
import 'package:barber_booking_app/services/master_services/master_time_slots_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MasterCreateTimeSlotScreen extends StatefulWidget {
  const MasterCreateTimeSlotScreen({super.key, required this.initialDate});

  final DateTime initialDate;

  @override
  State<MasterCreateTimeSlotScreen> createState() =>
      _MasterCreateTimeSlotScreenState();
}

class _MasterCreateTimeSlotScreenState extends State<MasterCreateTimeSlotScreen> {
  final MasterTimeSlotsService _service = MasterTimeSlotsService();
  late DateTime _date;
  late TimeOfDay _start;
  late TimeOfDay _end;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final d = widget.initialDate;
    _date = DateTime(d.year, d.month, d.day);
    _start = const TimeOfDay(hour: 9, minute: 0);
    _end = const TimeOfDay(hour: 10, minute: 0);
  }

  String _dateOnlyIso(DateTime d) {
    final y = d.year.toString().padLeft(4, '0');
    final m = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    return '$y-$m-$day';
  }

  String _timeIso(TimeOfDay t) {
    final h = t.hour.toString().padLeft(2, '0');
    final m = t.minute.toString().padLeft(2, '0');
    return '$h:$m:00';
  }

  String _formatTimeHm(TimeOfDay t) {
    final h = t.hour.toString().padLeft(2, '0');
    final m = t.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  bool _rangeValid() {
    final sm = _start.hour * 60 + _start.minute;
    final em = _end.hour * 60 + _end.minute;
    return em > sm;
  }

  bool get _selectedCalendarDateIsPast {
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
      setState(() => _date = DateTime(picked.year, picked.month, picked.day));
    }
  }

  Future<void> _pickStart() async {
    final t = await showTimePicker(
      context: context,
      initialTime: _start,
    );
    if (t != null) setState(() => _start = t);
  }

  Future<void> _pickEnd() async {
    final t = await showTimePicker(
      context: context,
      initialTime: _end,
    );
    if (t != null) setState(() => _end = t);
  }

  Future<void> _save() async {
    if (_selectedCalendarDateIsPast) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Нельзя создать слот на прошедшую дату'),
        ),
      );
      return;
    }
    if (!_rangeValid()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Время окончания должно быть позже начала')),
      );
      return;
    }
    setState(() => _saving = true);
    final err = await _service.createSlot(
      body: CreateTimeSlotRequest(
        ScheduleDate: _dateOnlyIso(_date),
        StartTime: _timeIso(_start),
        EndTime: _timeIso(_end),
      ),
    );
    if (!mounted) return;
    setState(() => _saving = false);
    if (err == null) {
      Navigator.of(context).pop(true);
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(err)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final df = DateFormat('dd.MM.yyyy');

    return MasterScreenScaffold(
      selectedTabIndex: MasterNav.slots,
      appBar: AppBar(
        title: const Text('Новый слот'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'Дата',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: cs.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: cs.outline.withValues(alpha: 0.2),
              ),
            ),
            child: ListTile(
              leading: Icon(Icons.calendar_today_outlined, color: cs.primary),
              title: Text(df.format(_date)),
              trailing: const Icon(Icons.chevron_right),
              onTap: _saving ? null : _pickDate,
            ),
          ),
          if (_selectedCalendarDateIsPast) ...[
            const SizedBox(height: 8),
            Text(
              'Укажите сегодняшнюю или будущую дату.',
              style: TextStyle(color: cs.onSurfaceVariant, fontSize: 13),
            ),
          ],
          const SizedBox(height: 20),
          Text(
            'Интервал',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: cs.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    title: const Text('Начало'),
                    subtitle: Text(_formatTimeHm(_start)),
                    onTap: _saving ? null : _pickStart,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    title: const Text('Конец'),
                    subtitle: Text(_formatTimeHm(_end)),
                    onTap: _saving ? null : _pickEnd,
                  ),
                ),
              ),
            ],
          ),
          if (!_rangeValid()) ...[
            const SizedBox(height: 12),
            Text(
              'Укажите время окончания позже начала',
              style: TextStyle(color: cs.error, fontSize: 13),
            ),
          ],
          const SizedBox(height: 32),
          FilledButton(
            onPressed: (_saving || _selectedCalendarDateIsPast) ? null : _save,
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: _saving
                ? const SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Создать слот'),
          ),
        ],
      ),
    );
  }
}
