import 'package:barber_booking_app/utils/appointment_status_ru.dart';
import 'package:barber_booking_app/utils/appointment_time_display.dart';
import 'package:barber_booking_app/models/params/appointment_params/filter_appointments_params.dart';
import 'package:barber_booking_app/models/params/page_params.dart';
import 'package:barber_booking_app/utils/admin_last_salon_storage.dart';
import 'package:barber_booking_app/services/admin_export/admin_excel_export_service.dart';
import 'package:barber_booking_app/services/appointment_services/get_salon_appointments_admin_service.dart';
import 'package:barber_booking_app/providers/appointment_providers/get_salon_appointments_admin_provider.dart';
import 'package:barber_booking_app/providers/auth_providers/auth_provider.dart';
import 'package:barber_booking_app/providers/salon_providers/get_salons_admin_provider.dart';
import 'package:barber_booking_app/widgets/error_widget.dart';
import 'package:barber_booking_app/screens/admin/admin_client_profile_screen.dart';
import 'package:barber_booking_app/screens/admin/admin_master_profile_screen.dart';
import 'package:barber_booking_app/models/appointment_models/response/salon_appointment_admin_response.dart';
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

/// Фильтр по статусу (соответствует `FilterAppointments` на API).
enum _AdminApptStatusFilter {
  all,
  awaiting,
  completed,
  cancelled,
}

/// Пресет периода по дате создания записи (`ThisDay` / `ThisWeek` / `from`–`to` на API).
enum _AdminDatePreset {
  all,
  today,
  thisWeek,
  custom,
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
  _AdminDatePreset _datePreset = _AdminDatePreset.all;
  final PageParams _pageParams = PageParams(Page: 1, PageSize: 50);

  static const _chipDensity = VisualDensity(
    horizontal: VisualDensity.minimumDensity,
    vertical: VisualDensity.minimumDensity,
  );

  FilterAppointmentsParams _buildFilter() {
    final status = _statusFilter.toApiFilter;
    bool? tw;
    bool? td;
    DateTime? f;
    DateTime? t;
    switch (_datePreset) {
      case _AdminDatePreset.all:
        break;
      case _AdminDatePreset.today:
        td = true;
        break;
      case _AdminDatePreset.thisWeek:
        tw = true;
        break;
      case _AdminDatePreset.custom:
        f = _from;
        t = _to;
        break;
    }
    return FilterAppointmentsParams(
      confirmed: status?.confirmed,
      completed: status?.completed,
      cancelled: status?.cancelled,
      thisWeek: tw,
      thisDay: td,
      from: f,
      to: t,
    );
  }

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
        await AdminLastSalonStorage.write(preset);
        await _fetch();
      } else {
        final saved = await AdminLastSalonStorage.read();
        if (!mounted) return;
        final list = Provider.of<GetSalonsAdminProvider>(context, listen: false)
            .asSalonListItems;
        if (saved != null &&
            saved.isNotEmpty &&
            list.any((e) => e.Id == saved)) {
          setState(() => _salonId = saved);
          await _fetch();
        }
      }
    });
  }

  Future<void> _loadSalons() async {
    await Provider.of<GetSalonsAdminProvider>(context, listen: false)
        .load();
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
        _datePreset = _AdminDatePreset.custom;
        _from = DateTime(range.start.year, range.start.month, range.start.day);
        _to = DateTime(range.end.year, range.end.month, range.end.day, 23, 59, 59);
      });
      if (_salonId != null && _salonId!.isNotEmpty) {
        await _fetch();
      }
    }
  }

  Future<void> _fetch() async {
    if (_salonId == null || _salonId!.isEmpty) return;
    await Provider.of<GetSalonAppointmentsAdminProvider>(context, listen: false)
        .load(
      salonId: _salonId!,
      pageParams: _pageParams,
      filter: _buildFilter(),
    );
  }

  void _onStatusFilterChanged(_AdminApptStatusFilter value) {
    setState(() => _statusFilter = value);
    if (_salonId != null && _salonId!.isNotEmpty) {
      _fetch();
    }
  }

  void _onDatePresetChanged(_AdminDatePreset value) {
    setState(() {
      _datePreset = value;
      if (value != _AdminDatePreset.custom) {
        _from = null;
        _to = null;
      }
    });
    if (_salonId != null && _salonId!.isNotEmpty) {
      _fetch();
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
        'записи_${_salonId}_$stamp',
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

  String _periodSummary(DateFormat df) {
    switch (_datePreset) {
      case _AdminDatePreset.all:
        return 'Любая дата создания';
      case _AdminDatePreset.today:
        return 'Сегодня';
      case _AdminDatePreset.thisWeek:
        return 'Текущая неделя';
      case _AdminDatePreset.custom:
        if (_from != null && _to != null) {
          return '${df.format(_from!)} — ${df.format(_to!)}';
        }
        return 'Укажите диапазон';
    }
  }

  Widget _filterLabel(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
            ),
      ),
    );
  }

  Widget _statusChipRow(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    Widget chip(String label, _AdminApptStatusFilter v) {
      final sel = _statusFilter == v;
      return FilterChip(
        label: Text(label),
        selected: sel,
        showCheckmark: false,
        visualDensity: _chipDensity,
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        labelStyle: TextStyle(
          fontSize: 13,
          fontWeight: sel ? FontWeight.w600 : FontWeight.w500,
          color: sel ? cs.onSecondaryContainer : cs.onSurfaceVariant,
        ),
        selectedColor: cs.secondaryContainer,
        side: BorderSide(
          color: sel ? cs.secondaryContainer : cs.outlineVariant,
        ),
        onSelected: (_) => _onStatusFilterChanged(v),
      );
    }

    return SizedBox(
      height: 36,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          chip('Все', _AdminApptStatusFilter.all),
          const SizedBox(width: 6),
          chip('Ожидают', _AdminApptStatusFilter.awaiting),
          const SizedBox(width: 6),
          chip('Готово', _AdminApptStatusFilter.completed),
          const SizedBox(width: 6),
          chip('Отмена', _AdminApptStatusFilter.cancelled),
        ],
      ),
    );
  }

  Widget _dateChipRow(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    Widget chip(String label, _AdminDatePreset v) {
      final sel = _datePreset == v;
      return FilterChip(
        label: Text(label),
        selected: sel,
        showCheckmark: false,
        visualDensity: _chipDensity,
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        labelStyle: TextStyle(
          fontSize: 13,
          fontWeight: sel ? FontWeight.w600 : FontWeight.w500,
          color: sel ? cs.onTertiaryContainer : cs.onSurfaceVariant,
        ),
        selectedColor: cs.tertiaryContainer,
        side: BorderSide(
          color: sel ? cs.tertiaryContainer : cs.outlineVariant,
        ),
        onSelected: (_) => _onDatePresetChanged(v),
      );
    }

    return SizedBox(
      height: 36,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          chip('Все', _AdminDatePreset.all),
          const SizedBox(width: 6),
          chip('Сегодня', _AdminDatePreset.today),
          const SizedBox(width: 6),
          chip('Неделя', _AdminDatePreset.thisWeek),
          const SizedBox(width: 6),
          chip('Свой', _AdminDatePreset.custom),

        ],
      ),
    );
  }


  void _openClientProfile(BuildContext context, SalonAppointmentAdminResponse a) {
    final id = a.dtoUsersNavigation?.Id ?? a.ClientId;
    if (id == null || id.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Нет идентификатора клиента'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    Navigator.pushNamed(
      context,
      '/admin_client_profile',
      arguments: AdminClientProfileArgs(
        userId: id,
        previewName: a.dtoUsersNavigation?.Name,
      ),
    );
  }

  void _openMasterProfile(BuildContext context, SalonAppointmentAdminResponse a) {
    final id = a.dtoMasterProfileNavigation?.Id ?? a.MasterId;
    if (id == null || id.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Нет идентификатора мастера'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    Navigator.pushNamed(
      context,
      '/admin_master_profile',
      arguments: AdminMasterProfileArgs(
        masterId: id,
        previewName: a.dtoMasterProfileNavigation?.MasterName,
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    final df = DateFormat('dd.MM.yyyy');
    final cs = Theme.of(context).colorScheme;
    final canLoad = _salonId != null && _salonId!.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.initialSalonId != null
              ? 'Записи салона'
              : 'Записи за период',
        ),
        actions: [
          IconButton(
            tooltip: 'Экспорт Excel',
            onPressed: canLoad ? _exportToExcel : null,
            icon: const Icon(Icons.table_chart_outlined),
          ),
          IconButton(
            tooltip: 'Обновить список',
            onPressed: canLoad ? _fetch : null,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Material(
            color: cs.surfaceContainerLow,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
              child: Consumer<GetSalonsAdminProvider>(
                builder: (context, salons, _) {
                  final list = salons.asSalonListItems;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _filterLabel(context, 'САЛОН'),
                      DropdownButtonFormField<String>(
                        isDense: true,
                        isExpanded: true,
                        value: _salonId != null &&
                                list.any((e) => e.Id == _salonId)
                            ? _salonId
                            : null,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: cs.surface,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: cs.outlineVariant),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: cs.outlineVariant),
                          ),
                        ),
                        hint: const Text('Выберите салон'),
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
                      ),
                      const SizedBox(height: 10),
                      _filterLabel(context, 'СТАТУС'),
                      _statusChipRow(context),
                      const SizedBox(height: 8),
                      _filterLabel(context, 'СОЗДАНО'),
                      _dateChipRow(context),
                      const SizedBox(height: 8),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.calendar_today_rounded,
                            size: 16,
                            color: cs.onSurfaceVariant,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _periodSummary(df),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: cs.onSurfaceVariant,
                                    height: 1.25,
                                  ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _pickRange,
                              icon: const Icon(Icons.date_range_rounded, size: 18),
                              label: const Text('Календарь'),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                visualDensity: VisualDensity.compact,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton.filledTonal(
                            tooltip: 'Сбросить период',
                            onPressed: () {
                              setState(() {
                                _datePreset = _AdminDatePreset.all;
                                _from = null;
                                _to = null;
                              });
                              if (canLoad) _fetch();
                            },
                            icon: const Icon(Icons.restart_alt_rounded, size: 20),
                            style: IconButton.styleFrom(
                              visualDensity: VisualDensity.compact,
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
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
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        canLoad
                            ? 'Нет записей по выбранным условиям'
                            : 'Выберите салон',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  );
                }
                return RefreshIndicator(
                  onRefresh: _fetch,
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(12, 12, 12, 16),
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
                        margin: const EdgeInsets.only(bottom: 8),
                        elevation: 0,
                        color: cs.surfaceContainerHighest,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
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
                              _ClientTapRow(
                                client: client,
                                enabled: (a.dtoUsersNavigation?.Id ?? a.ClientId) != null &&
                                    (a.dtoUsersNavigation?.Id ?? a.ClientId)!.isNotEmpty,
                                onTap: () => _openClientProfile(context, a),
                              ),
                              _MasterTapRow(
                                name: master,
                                enabled: (a.dtoMasterProfileNavigation?.Id ?? a.MasterId) != null &&
                                    (a.dtoMasterProfileNavigation?.Id ?? a.MasterId)!.isNotEmpty,
                                onTap: () => _openMasterProfile(context, a),
                              ),
                              Text('Услуга: $service'),
                              const SizedBox(height: 4),
                              Chip(
                                label: Text(appointmentStatusLabelRu(a.Status)),
                                visualDensity: VisualDensity.compact,
                                materialTapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
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

class _ClientTapRow extends StatelessWidget {
  const _ClientTapRow({
    required this.client,
    required this.enabled,
    required this.onTap,
  });

  final String client;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Row(
            children: [
              Icon(
                Icons.person_rounded,
                size: 18,
                color: enabled ? cs.primary : cs.onSurfaceVariant,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Клиент: $client',
                  style: TextStyle(
                    color: enabled ? null : cs.onSurfaceVariant,
                  ),
                ),
              ),
              if (enabled)
                Icon(
                  Icons.chevron_right_rounded,
                  size: 20,
                  color: cs.onSurfaceVariant,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MasterTapRow extends StatelessWidget {
  const _MasterTapRow({
    required this.name,
    required this.enabled,
    required this.onTap,
  });

  final String name;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Row(
            children: [
              Icon(
                Icons.content_cut_rounded,
                size: 18,
                color: enabled ? cs.tertiary : cs.onSurfaceVariant,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Мастер: $name',
                  style: TextStyle(
                    color: enabled ? null : cs.onSurfaceVariant,
                  ),
                ),
              ),
              if (enabled)
                Icon(
                  Icons.chevron_right_rounded,
                  size: 20,
                  color: cs.onSurfaceVariant,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
