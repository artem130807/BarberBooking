import 'package:barber_booking_app/models/params/page_params.dart';
import 'package:barber_booking_app/models/params/salon_params/salon_filter.dart';
import 'package:barber_booking_app/providers/admin_top_services_provider.dart';
import 'package:barber_booking_app/providers/auth_providers/auth_provider.dart';
import 'package:barber_booking_app/providers/salon_providers/get_salons_provider.dart';
import 'package:barber_booking_app/widgets/error_widget.dart';
import 'package:barber_booking_app/widgets/loading_indicator.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AdminTopServicesScreen extends StatefulWidget {
  const AdminTopServicesScreen({super.key});

  @override
  State<AdminTopServicesScreen> createState() => _AdminTopServicesScreenState();
}

class _AdminTopServicesScreenState extends State<AdminTopServicesScreen> {
  String? _salonId;
  final SalonFilter _filter = SalonFilter();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminTopServicesProvider>().clearList();
      _loadSalons();
    });
  }

  Future<void> _loadSalons() async {
    final token = context.read<AuthProvider>().token;
    await context.read<GetSalonsProvider>().getSalons(
          PageParams(Page: 1, PageSize: 200),
          _filter,
          token,
        );
    if (mounted) setState(() {});
  }

  Future<void> _onSalonChanged(String? id) async {
    setState(() => _salonId = id);
    if (id == null || id.isEmpty) return;
    final token = context.read<AuthProvider>().token;
    await context.read<AdminTopServicesProvider>().load(id, token);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Топ услуг'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Услуги салона по числу записей (чем больше записей — тем выше в списке).',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                ),
                const SizedBox(height: 12),
                Consumer<GetSalonsProvider>(
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
                      onChanged: _onSalonChanged,
                    );
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: Consumer<AdminTopServicesProvider>(
              builder: (context, prov, _) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (prov.errorMessage != null && mounted) {
                    prov.showApiError(context, prov.errorMessage);
                  }
                });

                if (_salonId == null || _salonId!.isEmpty) {
                  return Center(
                    child: Text(
                      'Выберите салон',
                      style: TextStyle(color: cs.onSurfaceVariant),
                    ),
                  );
                }

                if (prov.isLoading && prov.items.isEmpty) {
                  return const Center(
                    child: LoadingIndicator(message: 'Загрузка...'),
                  );
                }

                if (prov.errorMessage != null && prov.items.isEmpty) {
                  return Center(
                    child: ErrorWidgetCustom(
                      message: prov.errorMessage!,
                      onRetry: () => _onSalonChanged(_salonId),
                    ),
                  );
                }

                if (prov.items.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.spa_outlined,
                            size: 48, color: cs.onSurfaceVariant),
                        const SizedBox(height: 12),
                        Text(
                          'В этом салоне пока нет услуг',
                          style: TextStyle(color: cs.onSurfaceVariant),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () => _onSalonChanged(_salonId),
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    itemCount: prov.items.length + (prov.hasMore ? 1 : 0),
                    itemBuilder: (context, i) {
                      if (i >= prov.items.length) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: Center(
                            child: prov.isLoading
                                ? const CircularProgressIndicator()
                                : TextButton(
                                    onPressed: () async {
                                      final t = context
                                          .read<AuthProvider>()
                                          .token;
                                      await prov.loadMore(t);
                                    },
                                    child: const Text('Загрузить ещё'),
                                  ),
                          ),
                        );
                      }
                      final s = prov.items[i];
                      final rank = i + 1;
                      final minutes = s.DurationMinutes;
                      final priceStr = s.Price != null
                          ? '${s.Price!.Value ?? ''} ₽'
                          : '';
                      return Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        elevation: 0,
                        color: cs.surfaceContainerHighest.withValues(alpha: 0.45),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: cs.outline.withValues(alpha: 0.12),
                          ),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          leading: CircleAvatar(
                            backgroundColor: cs.tertiaryContainer,
                            foregroundColor: cs.onTertiaryContainer,
                            child: Text(
                              '$rank',
                              style:
                                  const TextStyle(fontWeight: FontWeight.w700),
                            ),
                          ),
                          title: Text(
                            s.Name ?? '—',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Text(
                            [
                              if (minutes != null) '$minutes мин',
                              if (priceStr.isNotEmpty) priceStr,
                            ].join(' · '),
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
