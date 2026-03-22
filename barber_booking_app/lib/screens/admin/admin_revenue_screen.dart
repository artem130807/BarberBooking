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

class AdminRevenueScreen extends StatefulWidget {
  const AdminRevenueScreen({super.key});

  @override
  State<AdminRevenueScreen> createState() => _AdminRevenueScreenState();
}

class _AdminRevenueScreenState extends State<AdminRevenueScreen> {
  String? _salonId;
  DateTime? _from;
  DateTime? _to;
  final SalonFilter _filter = SalonFilter();

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

  Future<void> _calc() async {
    if (_salonId == null || _salonId!.isEmpty) return;
    final token = Provider.of<AuthProvider>(context, listen: false).token;
    await Provider.of<GetSalonAppointmentsAdminProvider>(context, listen: false)
        .loadAllPagesForRevenue(
      salonId: _salonId!,
      from: _from,
      to: _to,
      token: token,
    );
  }

  @override
  Widget build(BuildContext context) {
    final df = DateFormat('dd.MM.yyyy');
    final money = NumberFormat('#,##0.00', 'ru_RU');
    return Scaffold(
      appBar: AppBar(
        title: const Text('Выручка'),
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
          ListTile(
            title: const Text('Период'),
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
