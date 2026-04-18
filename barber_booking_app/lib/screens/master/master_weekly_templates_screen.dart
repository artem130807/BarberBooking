import 'package:barber_booking_app/models/master_interface_models/response/weekly_template_short_info.dart';
import 'package:barber_booking_app/screens/master/master_navigation.dart';
import 'package:barber_booking_app/providers/auth_providers/auth_provider.dart';
import 'package:barber_booking_app/screens/master/master_create_weekly_template_screen.dart';
import 'package:barber_booking_app/screens/master/master_weekly_template_detail_screen.dart';
import 'package:barber_booking_app/services/master_services/weekly_template_service.dart';
import 'package:barber_booking_app/widgets/loading_indicator.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MasterWeeklyTemplatesScreen extends StatefulWidget {
  const MasterWeeklyTemplatesScreen({super.key});

  @override
  State<MasterWeeklyTemplatesScreen> createState() =>
      _MasterWeeklyTemplatesScreenState();
}

class _MasterWeeklyTemplatesScreenState extends State<MasterWeeklyTemplatesScreen> {
  final WeeklyTemplateService _service = WeeklyTemplateService();
  List<WeeklyTemplateShortInfo> _items = [];
  bool _loading = true;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final list = await _service.fetchTemplates();
    if (!mounted) return;
    setState(() {
      if (list == null) {
        _loadError = 'Не удалось загрузить список';
        _items = [];
      } else {
        _loadError = null;
        _items = list;
      }
      _loading = false;
    });
  }

  Future<void> _openCreate() async {
    final created = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => const MasterCreateWeeklyTemplateScreen(),
      ),
    );
    if (created == true && mounted) await _load();
  }

  Future<void> _openDetail(WeeklyTemplateShortInfo t) async {
    final id = t.id;
    if (id == null || id.isEmpty) return;
    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => MasterWeeklyTemplateDetailScreen(templateId: id),
      ),
    );
    if (changed == true && mounted) await _load();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return MasterScreenScaffold(
      selectedTabIndex: MasterNav.slots,
      appBar: AppBar(
        title: const Text('Недельные шаблоны'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openCreate,
        icon: const Icon(Icons.add),
        label: const Text('Новый шаблон'),
      ),
      body: _loading
          ? const Center(child: LoadingIndicator(message: 'Загрузка…'))
          : RefreshIndicator(
              onRefresh: _load,
              child: _loadError != null
                  ? ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(32),
                          child: Column(
                            children: [
                              Text(
                                _loadError!,
                                textAlign: TextAlign.center,
                                style: TextStyle(color: cs.error),
                              ),
                              const SizedBox(height: 16),
                              FilledButton.tonal(
                                onPressed: _load,
                                child: const Text('Повторить'),
                              ),
                            ],
                          ),
                        ),
                      ],
                    )
                  : _items.isEmpty
                  ? ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.5,
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.all(32),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.view_week_outlined,
                                    size: 64,
                                    color: cs.onSurfaceVariant.withValues(alpha: 0.45),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Пока нет шаблонов',
                                    style: Theme.of(context).textTheme.titleMedium,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Создайте шаблон и добавьте в него дни с рабочими часами. '
                                    'Позже по шаблону можно массово создать слоты.',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: cs.onSurfaceVariant,
                                      height: 1.35,
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  FilledButton.tonal(
                                    onPressed: _openCreate,
                                    child: const Text('Создать шаблон'),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
                      itemCount: _items.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, i) {
                        final t = _items[i];
                        final name = t.name ?? 'Без названия';
                        final n = t.templateDayCount ?? 0;
                        final active = t.isActive ?? true;
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
                              onTap: () => _openDetail(t),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 14,
                                ),
                                child: Row(
                                  children: [
                                    DecoratedBox(
                                      decoration: BoxDecoration(
                                        color: cs.primaryContainer,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: SizedBox(
                                        width: 48,
                                        height: 48,
                                        child: Icon(
                                          Icons.view_week_rounded,
                                          color: cs.onPrimaryContainer,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            name,
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleMedium
                                                ?.copyWith(
                                                  fontWeight: FontWeight.w700,
                                                ),
                                          ),
                                          const SizedBox(height: 6),
                                          Wrap(
                                            spacing: 8,
                                            runSpacing: 4,
                                            children: [
                                              Chip(
                                                visualDensity: VisualDensity.compact,
                                                label: Text(
                                                  n == 0
                                                      ? 'Дни не заданы'
                                                      : 'Дней в шаблоне: $n',
                                                  style: const TextStyle(fontSize: 12),
                                                ),
                                                padding: EdgeInsets.zero,
                                                materialTapTargetSize:
                                                    MaterialTapTargetSize.shrinkWrap,
                                              ),
                                              if (!active)
                                                Chip(
                                                  visualDensity: VisualDensity.compact,
                                                  label: const Text(
                                                    'Неактивен',
                                                    style: TextStyle(fontSize: 12),
                                                  ),
                                                  padding: EdgeInsets.zero,
                                                  materialTapTargetSize:
                                                      MaterialTapTargetSize.shrinkWrap,
                                                ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    Icon(
                                      Icons.chevron_right_rounded,
                                      color: cs.onSurfaceVariant.withValues(alpha: 0.65),
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
    );
  }
}
