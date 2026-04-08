import 'package:barber_booking_app/models/master_interface_models/request/create_template_day_request.dart';
import 'package:barber_booking_app/screens/master/master_navigation.dart';
import 'package:barber_booking_app/providers/auth_providers/auth_provider.dart';
import 'package:barber_booking_app/services/master_services/weekly_template_service.dart';
import 'package:barber_booking_app/utils/weekday_template_api.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MasterAddTemplateDayScreen extends StatefulWidget {
  const MasterAddTemplateDayScreen({
    super.key,
    required this.weeklyTemplateId,
    required this.usedApiDays,
  });

  final String weeklyTemplateId;
  final Set<int> usedApiDays;

  @override
  State<MasterAddTemplateDayScreen> createState() =>
      _MasterAddTemplateDayScreenState();
}

class _MasterAddTemplateDayScreenState extends State<MasterAddTemplateDayScreen> {
  final WeeklyTemplateService _service = WeeklyTemplateService();
  late int _day;
  TimeOfDay _start = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _end = const TimeOfDay(hour: 18, minute: 0);
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final available = templateDaysOrderedForPicker()
        .where((d) => !widget.usedApiDays.contains(d))
        .toList();
    _day = available.isNotEmpty ? available.first : 1;
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
    if (widget.usedApiDays.contains(_day)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Этот день уже добавлен')),
      );
      return;
    }
    final token = context.read<AuthProvider>().token;
    setState(() => _saving = true);
    final err = await _service.createTemplateDay(
      token: token,
      body: CreateTemplateDayRequest(
        weeklyTemplateId: widget.weeklyTemplateId,
        dayOfWeek: _day,
        workStartTime: _timeIso(_start),
        workEndTime: _timeIso(_end),
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
    final available = templateDaysOrderedForPicker()
        .where((d) => !widget.usedApiDays.contains(d))
        .toList();

    return MasterScreenScaffold(
      selectedTabIndex: MasterNav.slots,
      appBar: AppBar(
        title: const Text('День в шаблоне'),
      ),
      body: available.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Все дни недели уже добавлены (максимум 7).',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: cs.onSurfaceVariant),
                ),
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Text(
                  'Один шаблон может включать от 1 до 7 дней — каждый день недели только один раз.',
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
                      value: _day,
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
