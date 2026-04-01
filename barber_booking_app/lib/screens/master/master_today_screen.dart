import 'package:barber_booking_app/models/master_interface_models/response/get_master_appointments_short_response.dart';
import 'package:barber_booking_app/models/master_models/response/get_master_response.dart';
import 'package:barber_booking_app/providers/auth_providers/auth_provider.dart';
import 'package:barber_booking_app/services/master_services/master_appointments_list_service.dart';
import 'package:barber_booking_app/widgets/loading_indicator.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class MasterTodayScreen extends StatefulWidget {
  const MasterTodayScreen({super.key, required this.profile});

  final GetMasterResponse profile;

  @override
  State<MasterTodayScreen> createState() => _MasterTodayScreenState();
}

class _MasterTodayScreenState extends State<MasterTodayScreen> {
  final MasterAppointmentsListService _service = MasterAppointmentsListService();
  List<GetMasterAppointmentsShortResponse> _today = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    final token = context.read<AuthProvider>().token;
    setState(() => _loading = true);
    final all = await _service.fetchAll(token);
    final now = DateTime.now();
    final today = all.where((a) {
      final raw = a.AppointmentDate;
      if (raw == null || raw.isEmpty) return false;
      final d = DateTime.tryParse(raw);
      if (d == null) return false;
      final l = d.toLocal();
      return l.year == now.year && l.month == now.month && l.day == now.day;
    }).toList()
      ..sort((a, b) {
        final ta = a.StartTime ?? '';
        final tb = b.StartTime ?? '';
        return ta.compareTo(tb);
      });
    if (!mounted) return;
    setState(() {
      _today = today;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final df = DateFormat('dd.MM.yyyy');
    final name = widget.profile.UserName ?? 'Мастер';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Сегодня'),
        automaticallyImplyLeading: false,
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Здравствуйте, $name',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      df.format(DateTime.now()),
                      style: TextStyle(
                        color: cs.onSurfaceVariant,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: cs.outline.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Icon(Icons.event_available, color: cs.primary),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _loading
                                    ? 'Загрузка…'
                                    : 'Записей на сегодня: ${_today.length}',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (_loading)
              const SliverFillRemaining(
                child: Center(child: LoadingIndicator(message: 'Загрузка записей…')),
              )
            else if (_today.isEmpty)
              SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.event_busy_outlined,
                        size: 56,
                        color: cs.onSurfaceVariant.withValues(alpha: 0.5),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'На сегодня записей нет',
                        style: TextStyle(color: cs.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 24),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, i) {
                      final a = _today[i];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          leading: CircleAvatar(
                            backgroundColor: cs.primaryContainer,
                            child: Icon(Icons.person, color: cs.onPrimaryContainer),
                          ),
                          title: Text(
                            a.UserName ?? 'Клиент',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Text(
                            '${a.ServiceName ?? '—'} · ${a.StartTime ?? ''}–${a.EndTime ?? ''}',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
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
                    childCount: _today.length,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
