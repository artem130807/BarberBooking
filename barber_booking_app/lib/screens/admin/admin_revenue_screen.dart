import 'package:barber_booking_app/models/params/appointment_params/filter_appointments_params.dart';
import 'package:barber_booking_app/providers/appointment_providers/get_salon_appointments_admin_provider.dart';
import 'package:barber_booking_app/providers/auth_providers/auth_provider.dart';
import 'package:barber_booking_app/providers/salon_providers/get_salons_admin_provider.dart';
import 'package:barber_booking_app/utils/admin_last_salon_storage.dart';
import 'package:barber_booking_app/services/admin_export/admin_excel_export_service.dart';
import 'package:barber_booking_app/services/appointment_services/get_salon_appointments_admin_service.dart';
import 'package:barber_booking_app/widgets/error_widget.dart';
import 'package:barber_booking_app/widgets/loading_indicator.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class AdminRevenueScreen extends StatefulWidget {
  const AdminRevenueScreen({super.key});

  @override
  State<AdminRevenueScreen> createState() => _AdminRevenueScreenState();
}

enum _RevenueDatePreset {
  all,
  today,
  thisWeek,
  custom,
}

class _AdminRevenueScreenState extends State<AdminRevenueScreen> {
  String? _salonId;
  DateTime? _from;
  DateTime? _to;
  _RevenueDatePreset _datePreset = _RevenueDatePreset.all;
  FilterAppointmentsParams _buildFilter() {
    switch (_datePreset) {
      case _RevenueDatePreset.all:
        return const FilterAppointmentsParams(completed: true);
      case _RevenueDatePreset.today:
        return const FilterAppointmentsParams(completed: true, thisDay: true);
      case _RevenueDatePreset.thisWeek:
        return const FilterAppointmentsParams(completed: true, thisWeek: true);
      case _RevenueDatePreset.custom:
        return FilterAppointmentsParams(
          completed: true,
          from: _from,
          to: _to,
        );
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<GetSalonAppointmentsAdminProvider>(context, listen: false)
          .clearList();
      _loadSalons();
    });
  }

  Future<void> _loadSalons() async {
    await Provider.of<GetSalonsAdminProvider>(context, listen: false)
        .load();
    if (!mounted) return;
    final saved = await AdminLastSalonStorage.read();
    if (!mounted) return;
    final list =
        Provider.of<GetSalonsAdminProvider>(context, listen: false)
            .asSalonListItems;
    if (saved != null &&
        saved.isNotEmpty &&
        list.any((e) => e.Id == saved)) {
      setState(() => _salonId = saved);
    } else {
      setState(() {});
    }
  }

  Future<void> _pickRange() async {
    final now = DateTime.now();
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 2),
      lastDate: DateTime(now.year + 1),
      initialDateRange: _from != null && _to != null
          ? DateTimeRange(start: _from!, end: _to!)
          : null,
    );
    if (range != null && mounted) {
      setState(() {
        _datePreset = _RevenueDatePreset.custom;
        _from = DateTime(range.start.year, range.start.month, range.start.day);
        _to = DateTime(range.end.year, range.end.month, range.end.day, 23, 59, 59);
      });
      if (_salonId != null && _salonId!.isNotEmpty) {
        await _calc();
      }
    }
  }

  Future<void> _calc() async {
    if (_salonId == null || _salonId!.isEmpty) return;
    await Provider.of<GetSalonAppointmentsAdminProvider>(context, listen: false)
        .loadAllPagesForRevenue(
      salonId: _salonId!,
      filter: _buildFilter(),
    );
  }

  void _onDatePresetChanged(_RevenueDatePreset value) {
    setState(() {
      _datePreset = value;
      if (value != _RevenueDatePreset.custom) {
        _from = null;
        _to = null;
      }
    });
    if (_salonId != null && _salonId!.isNotEmpty) {
      _calc();
    }
  }

  String _periodSubtitle(DateFormat df) {
    switch (_datePreset) {
      case _RevenueDatePreset.all:
        return 'Без ограничения по дате создания записи';
      case _RevenueDatePreset.today:
        return 'Созданные сегодня';
      case _RevenueDatePreset.thisWeek:
        return 'Созданные на текущей неделе (пн–вс, по дате создания)';
      case _RevenueDatePreset.custom:
        if (_from != null && _to != null) {
          return '${df.format(_from!)} — ${df.format(_to!)}';
        }
        return 'Выберите диапазон в календаре';
    }
  }

  Future<void> _exportToExcel() async {
    if (_salonId == null || _salonId!.isEmpty) return;
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const Center(child: CircularProgressIndicator()),
    );
    try {
      final rows = await GetSalonAppointmentsAdminService().fetchAllPages(
        _salonId!,
        filter: _buildFilter(),
      );
      if (!mounted) return;
      Navigator.of(context).pop();
      if (rows.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Нет данных для экспорта')),
        );
        return;
      }
      final stamp = DateFormat('yyyyMMdd_HHmm').format(DateTime.now());
      await AdminExcelExportService.instance.shareAppointments(
        rows,
        'выручка_${_salonId}_$stamp',
        includeRevenueSummary: true,
      );
    } catch (_) {
      if (mounted) Navigator.of(context).pop();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Не удалось экспортировать')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final df = DateFormat('dd.MM.yyyy');
    final money = NumberFormat('#,##0.00', 'ru_RU');
    return Scaffold(
      appBar: AppBar(
        title: const Text('Выручка'),
        actions: [
          IconButton(
            tooltip: 'Экспорт Excel',
            onPressed: _salonId == null ? null : _exportToExcel,
            icon: const Icon(Icons.table_chart_outlined),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Consumer<GetSalonsAdminProvider>(
              builder: (context, salons, _) {
                final list = salons.asSalonListItems;
                return DropdownButtonFormField<String>(
                  value: _salonId != null &&
                          list.any((e) => e.Id == _salonId)
                      ? _salonId
                      : null,
                  decoration: const InputDecoration(
                    labelText: 'Салон',
                    border: OutlineInputBorder(),
                  ),
                  items: list
                      .where((e) => e.Id != null && e.Id!.isNotEmpty)
                      .map(
                        (e) => DropdownMenuItem(
                          value: e.Id,
                          child: Text(
                            e.Name ?? '—',
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (v) async {
                    setState(() => _salonId = v);
                    await AdminLastSalonStorage.write(v);
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Период (дата создания записи)',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    FilterChip(
                      label: const Text('Все'),
                      selected: _datePreset == _RevenueDatePreset.all,
                      onSelected: (_) => _onDatePresetChanged(_RevenueDatePreset.all),
                    ),
                    FilterChip(
                      label: const Text('Сегодня'),
                      selected: _datePreset == _RevenueDatePreset.today,
                      onSelected: (_) =>
                          _onDatePresetChanged(_RevenueDatePreset.today),
                    ),
                    FilterChip(
                      label: const Text('Эта неделя'),
                      selected: _datePreset == _RevenueDatePreset.thisWeek,
                      onSelected: (_) =>
                          _onDatePresetChanged(_RevenueDatePreset.thisWeek),
                    ),
                    FilterChip(
                      label: const Text('Свой период'),
                      selected: _datePreset == _RevenueDatePreset.custom,
                      onSelected: (_) =>
                          setState(() => _datePreset = _RevenueDatePreset.custom),
                    ),
                  ],
                ),
              ],
            ),
          ),
          ListTile(
            title: const Text('Диапазон дат'),
            subtitle: Text(_periodSubtitle(df)),
            trailing: const Icon(Icons.date_range),
            onTap: _pickRange,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: OutlinedButton(
              onPressed: () {
                setState(() {
                  _datePreset = _RevenueDatePreset.all;
                  _from = null;
                  _to = null;
                });
                if (_salonId != null && _salonId!.isNotEmpty) {
                  _calc();
                }
              },
              child: const Text('Сбросить период'),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: FilledButton(
              onPressed: _salonId == null ? null : _calc,
              child: const Text('Рассчитать'),
            ),
          ),
          Expanded(
            child: Consumer<GetSalonAppointmentsAdminProvider>(
              builder: (context, prov, _) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (prov.errorMessage != null && mounted) {
                    prov.showApiError(context, prov.errorMessage);
                  }
                });
                if (prov.isLoading && prov.list == null) {
                  return const Center(
                    child: LoadingIndicator(message: 'Сбор данных...'),
                  );
                }
                if (prov.errorMessage != null && prov.list == null) {
                  return Center(
                    child: ErrorWidgetCustom(
                      message: prov.errorMessage!,
                      onRetry: _calc,
                    ),
                  );
                }
                if (prov.list == null) {
                  return Center(
                    child: Text(
                      'Выберите салон и нажмите «Рассчитать»',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  );
                }
                final sum = prov.sumCompletedRevenue();
                final n = prov.countCompleted();
                return RefreshIndicator(
                  onRefresh: _calc,
                  child: ListView(
                    padding: const EdgeInsets.all(24),
                    children: [
                      Text(
                        'Завершённые записи',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '$n шт.',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Сумма по услугам',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${money.format(sum)} ₽',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
