import 'package:barber_booking_app/models/master_interface_models/response/get_master_appointments_short_response.dart';
import 'package:barber_booking_app/models/master_interface_models/slot_appointment_status_filter.dart';
import 'package:barber_booking_app/providers/auth_providers/auth_provider.dart';
import 'package:barber_booking_app/screens/master/master_appointment_detail_screen.dart';
import 'package:barber_booking_app/screens/master/master_navigation.dart';
import 'package:barber_booking_app/services/master_services/master_slot_appointments_service.dart';
import 'package:barber_booking_app/utils/appointment_time_format.dart';
import 'package:barber_booking_app/widgets/loading_indicator.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

enum _SlotStatusScope {
  all,
  confirmed,
  completed,
  cancelled,
}

class MasterSlotAppointmentsScreen extends StatefulWidget {
  const MasterSlotAppointmentsScreen({
    super.key,
    required this.timeSlotId,
    this.slotTimeLabel,
  });

  final String timeSlotId;
  final String? slotTimeLabel;

  @override
  State<MasterSlotAppointmentsScreen> createState() =>
      _MasterSlotAppointmentsScreenState();
}

class _MasterSlotAppointmentsScreenState
    extends State<MasterSlotAppointmentsScreen> {
  final MasterSlotAppointmentsService _service = MasterSlotAppointmentsService();
  List<GetMasterAppointmentsShortResponse> _items = [];
  bool _loading = true;
  _SlotStatusScope _scope = _SlotStatusScope.all;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  SlotAppointmentStatusFilter? _filterForScope() {
    switch (_scope) {
      case _SlotStatusScope.all:
        return null;
      case _SlotStatusScope.confirmed:
        return const SlotAppointmentStatusFilter(confirmed: true);
      case _SlotStatusScope.completed:
        return const SlotAppointmentStatusFilter(completed: true);
      case _SlotStatusScope.cancelled:
        return const SlotAppointmentStatusFilter(cancelled: true);
    }
  }

  Future<void> _load() async {
    final token = context.read<AuthProvider>().token;
    setState(() => _loading = true);
    final page = await _service.fetchByTimeSlot(
      timeSlotId: widget.timeSlotId,
      statusFilter: _filterForScope(),
    );
    if (!mounted) return;
    setState(() {
      _items = page?.data ?? [];
      _loading = false;
    });
  }

  void _setScope(_SlotStatusScope next) {
    if (_scope == next) return;
    setState(() => _scope = next);
    _load();
  }

  String _dateLabel(String? raw) {
    if (raw == null || raw.isEmpty) return '—';
    final d = DateTime.tryParse(raw);
    if (d == null) return raw;
    return DateFormat('dd.MM.yyyy').format(d.toLocal());
  }

  String _statusRu(String? s) {
    switch (s) {
      case 'Confirmed':
        return 'Подтверждена';
      case 'Completed':
        return 'Завершена';
      case 'Cancelled':
        return 'Отменена';
      default:
        return s ?? '—';
    }
  }

  Widget _chip(String label, _SlotStatusScope scope) {
    final selected = _scope == scope;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: selected,
        showCheckmark: false,
        onSelected: (v) {
          if (!v) return;
          _setScope(scope);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final cardShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
      side: BorderSide(color: cs.outline.withValues(alpha: 0.2)),
    );

    final appBarFg = Theme.of(context).appBarTheme.foregroundColor ??
        Theme.of(context).colorScheme.onSurface;

    return MasterScreenScaffold(
      selectedTabIndex: MasterNav.slots,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Записи на слот'),
            if (widget.slotTimeLabel != null &&
                widget.slotTimeLabel!.isNotEmpty) ...[
              const SizedBox(height: 2),
              Text(
                widget.slotTimeLabel!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: appBarFg.withValues(alpha: 0.72),
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ],
          ],
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              children: [
                _chip('Все', _SlotStatusScope.all),
                _chip('Активные', _SlotStatusScope.confirmed),
                _chip('Завершённые', _SlotStatusScope.completed),
                _chip('Отменённые', _SlotStatusScope.cancelled),
              ],
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: LoadingIndicator(message: 'Загрузка…'))
                : RefreshIndicator(
                    onRefresh: _load,
                    child: _items.isEmpty
                        ? ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            children: [
                              SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.32,
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.event_busy_outlined,
                                        size: 56,
                                        color: cs.onSurfaceVariant
                                            .withValues(alpha: 0.45),
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        _scope == _SlotStatusScope.all
                                            ? 'На этот слот записей нет'
                                            : 'Нет записей с выбранным статусом',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            color: cs.onSurfaceVariant),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                            itemCount: _items.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 10),
                            itemBuilder: (context, i) {
                              final a = _items[i];
                              return Card(
                                margin: EdgeInsets.zero,
                                clipBehavior: Clip.antiAlias,
                                shape: cardShape,
                                child: ListTile(
                                  onTap: a.Id == null || a.Id!.isEmpty
                                      ? null
                                      : () async {
                                          final refreshed =
                                              await Navigator.of(context)
                                                  .push<bool>(
                                            MaterialPageRoute(
                                              builder: (_) =>
                                                  MasterAppointmentDetailScreen(
                                                appointmentId: a.Id!,
                                                masterNavTab: MasterNav.slots,
                                              ),
                                            ),
                                          );
                                          if (refreshed == true && mounted) {
                                            _load();
                                          }
                                        },
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 10,
                                  ),
                                  leading: CircleAvatar(
                                    backgroundColor: cs.secondaryContainer,
                                    child: Icon(
                                      Icons.content_cut,
                                      color: cs.onSecondaryContainer,
                                    ),
                                  ),
                                  title: Text(
                                    a.UserName ?? 'Клиент',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  titleAlignment: ListTileTitleAlignment.top,
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${_dateLabel(a.AppointmentDate)} · '
                                        '${formatAppointmentTimeHm(a.StartTime)}–'
                                        '${formatAppointmentTimeHm(a.EndTime)}\n'
                                        '${a.ServiceName ?? '—'}',
                                        maxLines: 4,
                                      ),
                                      const SizedBox(height: 6),
                                      Chip(
                                        visualDensity: VisualDensity.compact,
                                        label: Text(
                                          _statusRu(a.Status),
                                          style: const TextStyle(fontSize: 12),
                                        ),
                                        padding: EdgeInsets.zero,
                                        materialTapTargetSize:
                                            MaterialTapTargetSize.shrinkWrap,
                                      ),
                                    ],
                                  ),
                                  trailing: a.Price?.Value != null
                                      ? Text(
                                          '${a.Price!.Value!.toStringAsFixed(0)} ₽',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            color: cs.primary,
                                          ),
                                        )
                                      : null,
                                ),
                              );
                            },
                          ),
                  ),
          ),
        ],
      ),
    );
  }
}
