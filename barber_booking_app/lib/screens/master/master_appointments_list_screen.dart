import 'package:barber_booking_app/models/master_interface_models/response/get_master_appointments_short_response.dart';
import 'package:barber_booking_app/providers/auth_providers/auth_provider.dart';
import 'package:barber_booking_app/services/master_services/master_appointments_list_service.dart';
import 'package:barber_booking_app/widgets/loading_indicator.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    final token = context.read<AuthProvider>().token;
    setState(() => _loading = true);
    final list = await _service.fetchAll(token);
    if (!mounted) return;
    setState(() {
      _items = list;
      _loading = false;
    });
  }

  String _dateLabel(String? raw) {
    if (raw == null || raw.isEmpty) return '—';
    final d = DateTime.tryParse(raw);
    if (d == null) return raw;
    return DateFormat('dd.MM.yyyy').format(d.toLocal());
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Записи'),
        automaticallyImplyLeading: false,
      ),
      body: _loading
          ? const Center(child: LoadingIndicator(message: 'Загрузка…'))
          : RefreshIndicator(
              onRefresh: _load,
              child: _items.isEmpty
                  ? ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.5,
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
                            subtitle: Text(
                              '${_dateLabel(a.AppointmentDate)} · '
                              '${a.StartTime ?? ''}–${a.EndTime ?? ''}\n'
                              '${a.ServiceName ?? '—'}',
                              maxLines: 3,
                            ),
                            isThreeLine: true,
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
    );
  }
}
