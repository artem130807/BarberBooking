import 'package:barber_booking_app/models/master_interface_models/master_appointment_query_filter.dart';
import 'package:barber_booking_app/models/master_interface_models/response/get_master_appointments_short_response.dart';
import 'package:barber_booking_app/providers/auth_providers/auth_provider.dart';
import 'package:barber_booking_app/screens/master/master_appointment_detail_screen.dart';
import 'package:barber_booking_app/services/master_services/master_appointments_list_service.dart';
import 'package:barber_booking_app/utils/appointment_time_format.dart';
import 'package:barber_booking_app/widgets/loading_indicator.dart';
import 'package:barber_booking_app/widgets/master/master_notification_app_bar_button.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

enum _AppointmentScope {
  all,
  confirmed,
  completed,
  cancelled,
  thisWeek,
  thisMonth,
}

class MasterAppointmentsListScreen extends StatefulWidget {
  const MasterAppointmentsListScreen({super.key});

  @override
  State<MasterAppointmentsListScreen> createState() =>
      _MasterAppointmentsListScreenState();
}

class _MasterAppointmentsListScreenState
    extends State<MasterAppointmentsListScreen> {
  final MasterAppointmentsListService _service = MasterAppointmentsListService();
  List<GetMasterAppointmentsShortResponse> _items = [];
  bool _loading = true;
  _AppointmentScope _scope = _AppointmentScope.all;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  MasterAppointmentQueryFilter? _filterForScope() {
    switch (_scope) {
      case _AppointmentScope.all:
        return null;
      case _AppointmentScope.confirmed:
        return const MasterAppointmentQueryFilter(confirmed: true);
      case _AppointmentScope.completed:
        return const MasterAppointmentQueryFilter(completed: true);
      case _AppointmentScope.cancelled:
        return const MasterAppointmentQueryFilter(cancelled: true);
      case _AppointmentScope.thisWeek:
        return const MasterAppointmentQueryFilter(thisWeek: true);
      case _AppointmentScope.thisMonth:
        return const MasterAppointmentQueryFilter(thisMonth: true);
    }
  }

  Future<void> _load() async {
    final token = context.read<AuthProvider>().token;
    setState(() => _loading = true);
    final page = await _service.fetchPage(
      token: token,
      filter: _filterForScope(),
      pageSize: 100,
    );
    if (!mounted) return;
    setState(() {
      _items = page?.data ?? [];
      _loading = false;
    });
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

  Widget _chip(String label, _AppointmentScope value) {
    final selected = _scope == value;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) {
          if (_scope == value) return;
          setState(() => _scope = value);
          _load();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Записи'),
        automaticallyImplyLeading: false,
        actions: const [MasterNotificationAppBarButton()],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
            child: Row(
              children: [
                _chip('Все', _AppointmentScope.all),
                _chip('Активные', _AppointmentScope.confirmed),
                _chip('Завершённые', _AppointmentScope.completed),
                _chip('Отменённые', _AppointmentScope.cancelled),
                _chip('Неделя', _AppointmentScope.thisWeek),
                _chip('Месяц', _AppointmentScope.thisMonth),
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
                                height: MediaQuery.of(context).size.height * 0.45,
                                child: Center(
                                  child: Text(
                                    'Нет записей',
                                    style: TextStyle(color: cs.onSurfaceVariant),
                                  ),
                                ),
                              ),
                            ],
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
                            itemCount: _items.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 8),
                            itemBuilder: (context, i) {
                              final a = _items[i];
                              return Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
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
                                    style: const TextStyle(fontWeight: FontWeight.w600),
                                  ),
                                  titleAlignment: ListTileTitleAlignment.top,
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${_dateLabel(a.AppointmentDate)} · '
                                        '${formatAppointmentTimeHm(a.StartTime)}–${formatAppointmentTimeHm(a.EndTime)}\n'
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
