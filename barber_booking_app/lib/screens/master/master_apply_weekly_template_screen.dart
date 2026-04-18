import 'package:barber_booking_app/providers/auth_providers/auth_provider.dart';
import 'package:barber_booking_app/screens/master/master_navigation.dart';
import 'package:barber_booking_app/services/master_services/weekly_template_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class MasterApplyWeeklyTemplateScreen extends StatefulWidget {
  const MasterApplyWeeklyTemplateScreen({
    super.key,
    required this.templateId,
    required this.templateName,
  });

  final String templateId;
  final String templateName;

  @override
  State<MasterApplyWeeklyTemplateScreen> createState() =>
      _MasterApplyWeeklyTemplateScreenState();
}

class _MasterApplyWeeklyTemplateScreenState
    extends State<MasterApplyWeeklyTemplateScreen> {
  final WeeklyTemplateService _service = WeeklyTemplateService();
  late DateTime _from;
  late DateTime _to;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final n = DateTime.now();
    final today = DateTime(n.year, n.month, n.day);
    _from = today;
    _to = today.add(const Duration(days: 13));
  }

  Future<void> _pickFrom() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _from,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 730)),
    );
    if (picked != null) {
      setState(() {
        _from = DateTime(picked.year, picked.month, picked.day);
        if (_to.isBefore(_from)) {
          _to = _from;
        }
      });
    }
  }

  Future<void> _pickTo() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _to.isBefore(_from) ? _from : _to,
      firstDate: _from,
      lastDate: DateTime.now().add(const Duration(days: 730)),
    );
    if (picked != null) {
      setState(() {
        _to = DateTime(picked.year, picked.month, picked.day);
      });
    }
  }

  Future<void> _submit() async {
    setState(() => _saving = true);
    final (msg, err) = await _service.createSlotsFromWeeklyTemplate(
      weeklyTemplateId: widget.templateId,
      dateFrom: _from,
      dateTo: _to,
    );
    if (!mounted) return;
    setState(() => _saving = false);
    if (err != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(err)),
      );
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg ?? 'Готово')),
    );
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final df = DateFormat('dd.MM.yyyy');

    return MasterScreenScaffold(
      selectedTabIndex: MasterNav.slots,
      appBar: AppBar(
        title: const Text('Слоты по шаблону'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            widget.templateName,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 12),
          Text(
            'За выбранный период будут созданы слоты на те дни недели и в те интервалы, '
            'которые заданы в шаблоне. Уже существующие слоты на то же время не дублируются.',
            style: TextStyle(
              color: cs.onSurfaceVariant,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Период',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 8),
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: cs.outline.withValues(alpha: 0.2)),
            ),
            child: Column(
              children: [
                ListTile(
                  title: const Text('С даты'),
                  subtitle: Text(df.format(_from)),
                  trailing: const Icon(Icons.calendar_today_outlined),
                  onTap: _saving ? null : _pickFrom,
                ),
                const Divider(height: 1),
                ListTile(
                  title: const Text('По дату'),
                  subtitle: Text(df.format(_to)),
                  trailing: const Icon(Icons.calendar_today_outlined),
                  onTap: _saving ? null : _pickTo,
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          FilledButton(
            onPressed: _saving ? null : _submit,
            child: _saving
                ? const SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Создать слоты'),
          ),
        ],
      ),
    );
  }
}
