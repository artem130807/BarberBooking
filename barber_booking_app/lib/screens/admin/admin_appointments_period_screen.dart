import 'package:barber_booking_app/utils/appointment_status_ru.dart';
import 'package:barber_booking_app/utils/appointment_time_display.dart';
import 'package:barber_booking_app/models/params/appointment_params/filter_appointments_params.dart';
import 'package:barber_booking_app/models/params/page_params.dart';
import 'package:barber_booking_app/models/params/salon_params/salon_filter.dart';
import 'package:barber_booking_app/providers/appointment_providers/get_salon_appointments_admin_provider.dart';
import 'package:barber_booking_app/providers/auth_providers/auth_provider.dart';
import 'package:barber_booking_app/providers/salon_providers/get_salons_provider.dart';
import 'package:barber_booking_app/widgets/error_widget.dart';
import 'package:barber_booking_app/widgets/loading_indicator.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class AdminAppointmentsPeriodScreen extends StatefulWidget {
  const AdminAppointmentsPeriodScreen({super.key, this.initialSalonId});

  final String? initialSalonId;

  @override
  State<AdminAppointmentsPeriodScreen> createState() =>
      _AdminAppointmentsPeriodScreenState();
}

/// Фильтр по статусу (соответствует `FilterAppointments` на API: Confirmed / Completed / Cancelled).
enum _AdminApptStatusFilter {
  all,
  awaiting,
  completed,
  cancelled,
}

extension on _AdminApptStatusFilter {
  FilterAppointmentsParams? get toApiFilter {
    switch (this) {
      case _AdminApptStatusFilter.all:
        return null;
      case _AdminApptStatusFilter.awaiting:
        return FilterAppointmentsParams.awaiting();
      case _AdminApptStatusFilter.completed:
        return FilterAppointmentsParams.done();
      case _AdminApptStatusFilter.cancelled:
        return FilterAppointmentsParams.cancelledOnly();
    }
  }
}

class _AdminAppointmentsPeriodScreenState
    extends State<AdminAppointmentsPeriodScreen> {
  String? _salonId;
  DateTime? _from;
  DateTime? _to;
  _AdminApptStatusFilter _statusFilter = _AdminApptStatusFilter.all;
  final PageParams _pageParams = PageParams(Page: 1, PageSize: 50);
  final SalonFilter _filter = SalonFilter();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      Provider.of<GetSalonAppointmentsAdminProvider>(context, listen: false)
          .clearList();
      await _loadSalons();
      final preset = widget.initialSalonId;
      if (preset != null && preset.isNotEmpty && mounted) {
        setState(() => _salonId = preset);
        await _fetch();
      }
    });
  }

  Future<void> _loadSalons() async {
    final token = Provider.of<AuthProvider>(context, listen: false).token;
    await Provider.of<GetSalonsProvider>(context, listen: false)
        .getSalons(PageParams(Page: 1, PageSize: 200), _filter, token);
    if (mounted) setState(() {});
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
        _from = DateTime(range.start.year, range.start.month, range.start.day);
        _to = DateTime(range.end.year, range.end.month, range.end.day, 23, 59, 59);
      });
    }
  }

  Future<void> _fetch() async {
    if (_salonId == null || _salonId!.isEmpty) return;
    final token = Provider.of<AuthProvider>(context, listen: false).token;
    await Provider.of<GetSalonAppointmentsAdminProvider>(context, listen: false)
        .load(
      salonId: _salonId!,
      from: _from,
      to: _to,
      pageParams: _pageParams,
      token: token,
      statusFilter: _statusFilter.toApiFilter,
    );
  }

  void _onStatusFilterChanged(_AdminApptStatusFilter value) {
    setState(() => _statusFilter = value);
    if (_salonId != null && _salonId!.isNotEmpty) {
      _fetch();
    }
  }

  @override
  Widget build(BuildContext context) {
    final df = DateFormat('dd.MM.yyyy');
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.initialSalonId != null
              ? 'Записи салона'
              : 'Записи за период',
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Consumer<GetSalonsProvider>(
              builder: (context, salons, _) {
                final list = salons.getSalonsResponse ?? [];
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
                  onChanged: (v) => setState(() => _salonId = v),
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
                  'Статус записи',
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
                      selected: _statusFilter == _AdminApptStatusFilter.all,
                      onSelected: (_) =>
                          _onStatusFilterChanged(_AdminApptStatusFilter.all),
                    ),
                    FilterChip(
                      label: const Text('Ожидающие'),
                      selected:
                          _statusFilter == _AdminApptStatusFilter.awaiting,
                      onSelected: (_) => _onStatusFilterChanged(
                        _AdminApptStatusFilter.awaiting,
                      ),
                    ),
                    FilterChip(
                      label: const Text('Выполненные'),
                      selected:
                          _statusFilter == _AdminApptStatusFilter.completed,
                      onSelected: (_) => _onStatusFilterChanged(
                        _AdminApptStatusFilter.completed,
                      ),
                    ),
                    FilterChip(
                      label: const Text('Отменённые'),
                      selected:
                          _statusFilter == _AdminApptStatusFilter.cancelled,
                      onSelected: (_) => _onStatusFilterChanged(
                        _AdminApptStatusFilter.cancelled,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          ListTile(
            title: const Text('Период (дата создания записи)'),
            subtitle: Text(
              _from != null && _to != null
                  ? '${df.format(_from!)} — ${df.format(_to!)}'
                  : 'Не выбран — все записи',
            ),
            trailing: const Icon(Icons.date_range),
            onTap: _pickRange,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: OutlinedButton(
              onPressed: () => setState(() {
                _from = null;
                _to = null;
              }),
              child: const Text('Сбросить период'),
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: FilledButton(
              onPressed: _salonId == null ? null : _fetch,
              child: const Text('Загрузить'),
            ),
          ),
          const SizedBox(height: 8),
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
                    child: LoadingIndicator(message: 'Загрузка...'),
                  );
                }
                if (prov.errorMessage != null && prov.list == null) {
                  return Center(
                    child: ErrorWidgetCustom(
                      message: prov.errorMessage!,
                      onRetry: _fetch,
                    ),
                  );
                }
                final items = prov.list;
                if (items == null || items.isEmpty) {
                  return Center(
                    child: Text(
                      'Нет данных',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  );
                }
                return RefreshIndicator(
                  onRefresh: _fetch,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: items.length,
                    itemBuilder: (context, i) {
                      final a = items[i];
                      final client = a.dtoUsersNavigation?.Name ?? '—';
                      final master =
                          a.dtoMasterProfileNavigation?.MasterName ?? '—';
                      final service = a.dtoServicesNavigation?.Name ?? '—';
                      final dateStr = a.AppointmentDate != null
                          ? df.format(a.AppointmentDate!.toLocal())
                          : '—';
                      final timeStr = formatAppointmentSlotTime(a.StartTime);
                      return Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '$dateStr · $timeStr',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text('Клиент: $client'),
                              Text('Мастер: $master'),
                              Text('Услуга: $service'),
                              const SizedBox(height: 4),
                              Chip(
                                label: Text(appointmentStatusLabelRu(a.Status)),
                                visualDensity: VisualDensity.compact,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
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
