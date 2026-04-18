import 'package:barber_booking_app/models/master_interface_models/response/template_day_info.dart';
import 'package:barber_booking_app/screens/master/master_navigation.dart';
import 'package:barber_booking_app/models/master_interface_models/response/weekly_template_info.dart';
import 'package:barber_booking_app/providers/auth_providers/auth_provider.dart';
import 'package:barber_booking_app/screens/master/master_add_template_day_screen.dart';
import 'package:barber_booking_app/screens/master/master_edit_template_day_screen.dart';
import 'package:barber_booking_app/screens/master/master_apply_weekly_template_screen.dart';
import 'package:barber_booking_app/services/master_services/weekly_template_service.dart';
import 'package:barber_booking_app/utils/weekday_template_api.dart';
import 'package:barber_booking_app/widgets/loading_indicator.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MasterWeeklyTemplateDetailScreen extends StatefulWidget {
  const MasterWeeklyTemplateDetailScreen({
    super.key,
    required this.templateId,
  });

  final String templateId;

  @override
  State<MasterWeeklyTemplateDetailScreen> createState() =>
      _MasterWeeklyTemplateDetailScreenState();
}

class _MasterWeeklyTemplateDetailScreenState
    extends State<MasterWeeklyTemplateDetailScreen> {
  final WeeklyTemplateService _service = WeeklyTemplateService();
  WeeklyTemplateInfo? _info;
  List<TemplateDayInfo> _days = [];
  bool _loading = true;
  bool _loadFailed = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final info = await _service.fetchTemplateById(widget.templateId);
    final days = await _service.fetchTemplateDays(widget.templateId);
    if (!mounted) return;
    if (info == null) {
      setState(() {
        _loadFailed = true;
        _loading = false;
        _days = [];
      });
      return;
    }
    final d = days ?? [];
    d.sort((a, b) {
      final da = a.dayOfWeek ?? 0;
      final db = b.dayOfWeek ?? 0;
      return templateDaySortKey(da).compareTo(templateDaySortKey(db));
    });
    setState(() {
      _info = info;
      _days = d;
      _loadFailed = false;
      _loading = false;
    });
  }

  Set<int> get _usedDays =>
      _days.map((e) => e.dayOfWeek).whereType<int>().toSet();

  String _hm(String? s) {
    if (s == null || s.isEmpty) return '—';
    final p = s.split(':');
    if (p.length >= 2) {
      return '${p[0].padLeft(2, '0')}:${p[1].padLeft(2, '0')}';
    }
    return s;
  }

  Future<void> _confirmDeleteTemplate() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Удалить шаблон?'),
        content: const Text(
          'Все дни этого шаблона будут удалены. Действие нельзя отменить.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Отмена'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Удалить'),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    final err = await _service.deleteTemplate(id: widget.templateId);
    if (!mounted) return;
    if (err != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err)));
      return;
    }
    Navigator.of(context).pop(true);
  }

  Future<void> _confirmDeleteDay(TemplateDayInfo day) async {
    final id = day.id;
    if (id == null || id.isEmpty) return;
    final dow = day.dayOfWeek;
    final label = dow != null ? templateDayLongLabelRu(dow) : 'день';
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Удалить $label?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Отмена'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Удалить'),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    final err = await _service.deleteTemplateDay(id: id);
    if (!mounted) return;
    if (err != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err)));
      return;
    }
    await _load();
  }

  Future<void> _openEditDay(TemplateDayInfo day) async {
    final id = day.id;
    if (id == null || id.isEmpty) return;
    final otherUsed = _days
        .where((x) => x.id != day.id)
        .map((x) => x.dayOfWeek)
        .whereType<int>()
        .toSet();
    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => MasterEditTemplateDayScreen(
          day: day,
          otherUsedApiDays: otherUsed,
        ),
      ),
    );
    if (changed == true && mounted) await _load();
  }

  Future<void> _openAddDay() async {
    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => MasterAddTemplateDayScreen(
          weeklyTemplateId: widget.templateId,
          usedApiDays: _usedDays,
        ),
      ),
    );
    if (changed == true && mounted) await _load();
  }

  Future<void> _openApply() async {
    if (_days.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Добавьте хотя бы один день в шаблон'),
        ),
      );
      return;
    }
    final name = _info?.name ?? 'Шаблон';
    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => MasterApplyWeeklyTemplateScreen(
          templateId: widget.templateId,
          templateName: name,
        ),
      ),
    );
    if (changed == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Слоты можно посмотреть во вкладке «Слоты»')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return MasterScreenScaffold(
      selectedTabIndex: MasterNav.slots,
      appBar: AppBar(
        title: Text(_info?.name ?? 'Шаблон'),
        actions: [
          IconButton(
            tooltip: 'Удалить шаблон',
            onPressed: _loading ? null : _confirmDeleteTemplate,
            icon: const Icon(Icons.delete_outline),
          ),
        ],
      ),
      floatingActionButton: _loading
          ? null
          : _usedDays.length >= 7
              ? null
              : FloatingActionButton.extended(
                  onPressed: _openAddDay,
                  icon: const Icon(Icons.add),
                  label: const Text('День'),
                ),
      body: _loading
          ? const Center(child: LoadingIndicator(message: 'Загрузка…'))
          : _loadFailed
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Не удалось загрузить шаблон',
                          style: TextStyle(color: cs.error),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        FilledButton.tonal(
                          onPressed: _load,
                          child: const Text('Повторить'),
                        ),
                      ],
                    ),
                  ),
                )
              : ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
              children: [
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: cs.outline.withValues(alpha: 0.2)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                _info?.name ?? '—',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.w700,
                                    ),
                              ),
                            ),
                            if (_info?.isActive == false)
                              Chip(
                                label: const Text('Неактивен', style: TextStyle(fontSize: 12)),
                                visualDensity: VisualDensity.compact,
                                padding: EdgeInsets.zero,
                                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _days.isEmpty
                              ? 'Дни не настроены — добавьте хотя бы один, чтобы по шаблону создавать слоты.'
                              : 'В шаблоне ${_days.length} ${_daysWord(_days.length)} недели.',
                          style: TextStyle(color: cs.onSurfaceVariant, height: 1.35),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                FilledButton.tonalIcon(
                  onPressed: _openApply,
                  icon: const Icon(Icons.auto_fix_high_outlined),
                  label: const Text('Создать слоты по шаблону'),
                ),
                const SizedBox(height: 20),
                Text(
                  'Дни недели',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 8),
                if (_days.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(
                            Icons.event_busy_outlined,
                            size: 48,
                            color: cs.onSurfaceVariant.withValues(alpha: 0.45),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Нет дней',
                            style: TextStyle(color: cs.onSurfaceVariant),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Можно добавить от 1 до 7 дней',
                            style: TextStyle(
                              fontSize: 13,
                              color: cs.onSurfaceVariant.withValues(alpha: 0.85),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  ..._days.map((day) {
                    final dow = day.dayOfWeek;
                    final title = dow != null ? templateDayLongLabelRu(dow) : 'День';
                    final sub = '${_hm(day.workStartTime)} – ${_hm(day.workEndTime)}';
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Card(
                        margin: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: cs.outline.withValues(alpha: 0.2)),
                        ),
                        child: ListTile(
                          title: Text(title),
                          subtitle: Text(sub),
                          onTap: () => _openEditDay(day),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                tooltip: 'Изменить',
                                onPressed: () => _openEditDay(day),
                                icon: const Icon(Icons.edit_outlined),
                              ),
                              IconButton(
                                tooltip: 'Удалить',
                                onPressed: () => _confirmDeleteDay(day),
                                icon: Icon(Icons.close_rounded, color: cs.error),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
              ],
            ),
    );
  }

  String _daysWord(int n) {
    final m = n % 10;
    final m100 = n % 100;
    if (m100 >= 11 && m100 <= 14) return 'дней';
    if (m == 1) return 'день';
    if (m >= 2 && m <= 4) return 'дня';
    return 'дней';
  }
}
