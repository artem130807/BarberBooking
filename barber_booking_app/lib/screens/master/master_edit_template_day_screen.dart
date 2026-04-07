import 'package:barber_booking_app/models/master_interface_models/request/update_template_day_request.dart';
import 'package:barber_booking_app/models/master_interface_models/response/template_day_info.dart';
import 'package:barber_booking_app/providers/auth_providers/auth_provider.dart';
import 'package:barber_booking_app/services/master_services/weekly_template_service.dart';
import 'package:barber_booking_app/utils/weekday_template_api.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MasterEditTemplateDayScreen extends StatefulWidget {
  const MasterEditTemplateDayScreen({
    super.key,
    required this.day,
    required this.otherUsedApiDays,
  });

  final TemplateDayInfo day;
  final Set<int> otherUsedApiDays;

  @override
  State<MasterEditTemplateDayScreen> createState() =>
      _MasterEditTemplateDayScreenState();
}

class _MasterEditTemplateDayScreenState extends State<MasterEditTemplateDayScreen> {
  final WeeklyTemplateService _service = WeeklyTemplateService();
  late int _day;
  late TimeOfDay _start;
  late TimeOfDay _end;
  bool _saving = false;

  static TimeOfDay? _parseTime(String? s) {
    if (s == null || s.isEmpty) return null;
    final p = s.split(':');
    if (p.length < 2) return null;
    final h = int.tryParse(p[0].trim()) ?? 0;
    final m = int.tryParse(p[1].trim()) ?? 0;
    return TimeOfDay(hour: h.clamp(0, 23), minute: m.clamp(0, 59));
  }

  @override
  void initState() {
    super.initState();
    _day = widget.day.dayOfWeek ?? 1;
    _start = _parseTime(widget.day.workStartTime) ?? const TimeOfDay(hour: 9, minute: 0);
    _end = _parseTime(widget.day.workEndTime) ?? const TimeOfDay(hour: 18, minute: 0);
  }

  String _timeIso(TimeOfDay t) {
    final h = t.hour.toString().padLeft(2, '0');
    final m = t.minute.toString().padLeft(2, '0');
    return '$h:$m:00';
  }

  String _formatHm(TimeOfDay t) {
    final h = t.hour.toString().padLeft(2, '0');
    final m = t.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  bool _rangeValid() {
    final sm = _start.hour * 60 + _start.minute;
    final em = _end.hour * 60 + _end.minute;
    return em > sm;
  }

  List<int> get _availableDays {
    return templateDaysOrderedForPicker()
        .where((d) => !widget.otherUsedApiDays.contains(d) || d == _day)
        .toList();
  }

  Future<void> _pickStart() async {
    final t = await showTimePicker(context: context, initialTime: _start);
    if (t != null) setState(() => _start = t);
  }

  Future<void> _pickEnd() async {
    final t = await showTimePicker(context: context, initialTime: _end);
    if (t != null) setState(() => _end = t);
  }

  Future<void> _save() async {
    if (!_rangeValid()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Время окончания должно быть позже начала')),
      );
      return;
    }
    final id = widget.day.id;
    if (id == null || id.isEmpty) return;
    final token = context.read<AuthProvider>().token;
    setState(() => _saving = true);
    final err = await _service.updateTemplateDay(
      token: token,
      templateDayId: id,
      body: UpdateTemplateDayRequest(
        workStartTime: _timeIso(_start),
        workEndTime: _timeIso(_end),
        dayOfWeek: _day,
      ),
    );
    if (!mounted) return;
    setState(() => _saving = false);
    if (err != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err)));
      return;
    }
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final available = _availableDays;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Редактировать день'),
      ),
      body: available.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Нет доступных дней недели',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: cs.onSurfaceVariant),
                ),
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Text(
                  'Можно изменить день недели и рабочие часы. День недели не должен совпадать с другим днём в этом шаблоне.',
                  style: TextStyle(color: cs.onSurfaceVariant, height: 1.4),
                ),
                const SizedBox(height: 20),
                InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'День недели',
                    border: OutlineInputBorder(),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<int>(
                      isExpanded: true,
                      value: available.contains(_day) ? _day : available.first,
                      items: available
                          .map(
                            (d) => DropdownMenuItem(
                              value: d,
                              child: Text(templateDayLongLabelRu(d)),
                            ),
                          )
                          .toList(),
                      onChanged: _saving
                          ? null
                          : (v) {
                              if (v != null) setState(() => _day = v);
                            },
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _saving ? null : _pickStart,
                        child: Text('С ${_formatHm(_start)}'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _saving ? null : _pickEnd,
                        child: Text('До ${_formatHm(_end)}'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),
                FilledButton(
                  onPressed: (_saving || !_rangeValid()) ? null : _save,
                  child: _saving
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Сохранить'),
                ),
              ],
            ),
    );
  }
}
