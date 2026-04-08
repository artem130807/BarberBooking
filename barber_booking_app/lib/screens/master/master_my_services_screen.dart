import 'package:barber_booking_app/models/master_interface_models/response/master_service_link_response.dart';
import 'package:barber_booking_app/screens/master/master_navigation.dart';
import 'package:barber_booking_app/models/master_interface_models/response/salon_service_catalog_item.dart';
import 'package:barber_booking_app/providers/auth_providers/auth_provider.dart';
import 'package:barber_booking_app/services/master_services/master_services_api_service.dart';
import 'package:barber_booking_app/widgets/loading_indicator.dart';
import 'package:barber_booking_app/widgets/profile_shell_widgets.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MasterMyServicesScreen extends StatefulWidget {
  const MasterMyServicesScreen({
    super.key,
    required this.masterProfileId,
  });

  final String masterProfileId;

  @override
  State<MasterMyServicesScreen> createState() => _MasterMyServicesScreenState();
}

class _MasterMyServicesScreenState extends State<MasterMyServicesScreen> {
  final MasterServicesApiService _api = MasterServicesApiService();
  List<MasterServiceLinkResponse> _mine = [];
  List<SalonServiceCatalogItem> _catalog = [];
  bool _loading = true;
  String? _error;
  String? _catalogError;
  final Set<String> _adding = {};
  final Set<String> _removing = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    final token = context.read<AuthProvider>().token;
    if (widget.masterProfileId.isEmpty) {
      setState(() {
        _loading = false;
        _error = 'Профиль мастера не найден';
      });
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
      _catalogError = null;
    });
    final mine = await _api.fetchMasterServices(
      token: token,
      masterProfileId: widget.masterProfileId,
    );
    final (rawCatalog, catErr) = await _api.fetchSalonServicesForMaster(token: token);
    if (!mounted) return;
    if (mine == null) {
      setState(() {
        _mine = [];
        _catalog = [];
        _loading = false;
        _error = 'Не удалось загрузить ваши услуги';
        _catalogError = catErr;
      });
      return;
    }
    final filtered = (rawCatalog ?? [])
        .where((s) => s.isActive != false)
        .toList();
    setState(() {
      _mine = mine;
      _catalog = filtered;
      _catalogError = catErr;
      _loading = false;
      _error = null;
    });
  }

  Set<String> get _linkedServiceIds =>
      _mine.map((e) => e.serviceId).whereType<String>().toSet();

  List<SalonServiceCatalogItem> get _availableToAdd {
    final linked = _linkedServiceIds;
    return _catalog.where((s) => !linked.contains(s.id)).toList();
  }

  Future<void> _add(SalonServiceCatalogItem s) async {
    final token = context.read<AuthProvider>().token;
    setState(() => _adding.add(s.id));
    final err = await _api.addService(token: token, serviceId: s.id);
    if (!mounted) return;
    setState(() => _adding.remove(s.id));
    if (err != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err)));
      return;
    }
    await _load();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('«${s.name}» добавлена')),
      );
    }
  }

  Future<void> _confirmRemove(MasterServiceLinkResponse row) async {
    final id = row.id;
    final name = row.serviceName ?? 'Услуга';
    if (id == null || id.isEmpty) return;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Убрать услугу?'),
        content: Text(
          '«$name» больше не будет в списке услуг, по которым вы принимаете записи.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Отмена'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Убрать'),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    final token = context.read<AuthProvider>().token;
    setState(() => _removing.add(id));
    final err = await _api.removeService(token: token, masterServiceLinkId: id);
    if (!mounted) return;
    setState(() => _removing.remove(id));
    if (err != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err)));
      return;
    }
    await _load();
  }

  String _priceLabel(double? v) {
    if (v == null) return '';
    return '${v.toStringAsFixed(0)} ₽';
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return MasterScreenScaffold(
      selectedTabIndex: MasterNav.profile,
      appBar: AppBar(
        title: const Text('Мои услуги'),
      ),
      body: _loading
          ? const Center(child: LoadingIndicator(message: 'Загрузка…'))
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
                children: [
                  if (_error != null) ...[
                    Card(
                      color: cs.errorContainer,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Icon(Icons.error_outline, color: cs.onErrorContainer),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _error!,
                                style: TextStyle(color: cs.onErrorContainer),
                              ),
                            ),
                            TextButton(
                              onPressed: _load,
                              child: const Text('Повторить'),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  Text(
                    'Выберите услуги салона, по которым готовы принимать клиентов. '
                    'Только эти услуги можно будет выбрать при записи к вам.',
                    style: TextStyle(
                      color: cs.onSurfaceVariant,
                      height: 1.4,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ProfileSectionHeading(text: 'Подключённые услуги', colorScheme: cs),
                  const SizedBox(height: 8),
                  if (_mine.isEmpty)
                    Card(
                      margin: EdgeInsets.zero,
                      shape: profileCardShape(cs),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            Icon(
                              Icons.content_cut_outlined,
                              size: 40,
                              color: cs.onSurfaceVariant.withValues(alpha: 0.45),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Пока нет услуг',
                              style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Добавьте услуги из каталога салона ниже.',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: cs.onSurfaceVariant, fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    ..._mine.map((row) {
                      final linkId = row.id;
                      final busy = linkId != null && _removing.contains(linkId);
                      final title = row.serviceName ?? 'Услуга';
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Card(
                          margin: EdgeInsets.zero,
                          clipBehavior: Clip.antiAlias,
                          shape: profileCardShape(cs),
                          child: ListTile(
                            title: Text(title),
                            subtitle: Text(
                              'Услуга салона',
                              style: TextStyle(fontSize: 13, color: cs.onSurfaceVariant),
                            ),
                            trailing: busy
                                ? const SizedBox(
                                    width: 28,
                                    height: 28,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : IconButton(
                                    tooltip: 'Убрать',
                                    onPressed: linkId == null ? null : () => _confirmRemove(row),
                                    icon: Icon(Icons.remove_circle_outline, color: cs.error),
                                  ),
                          ),
                        ),
                      );
                    }),
                  const SizedBox(height: 24),
                  ProfileSectionHeading(
                    text: 'Каталог салона',
                    colorScheme: cs,
                  ),
                  const SizedBox(height: 8),
                  if (_catalogError != null)
                    Card(
                      color: cs.errorContainer.withValues(alpha: 0.65),
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.warning_amber_rounded, color: cs.onErrorContainer),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                _catalogError!,
                                style: TextStyle(
                                  color: cs.onErrorContainer,
                                  fontSize: 14,
                                  height: 1.35,
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: _load,
                              child: const Text('Повторить'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  if (_catalogError == null) ...[
                    if (_availableToAdd.isEmpty && _catalog.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Text(
                          'Все доступные услуги салона уже добавлены.',
                          style: TextStyle(color: cs.onSurfaceVariant),
                        ),
                      )
                    else if (_catalog.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Text(
                          'В каталоге салона нет активных услуг.',
                          style: TextStyle(color: cs.onSurfaceVariant),
                        ),
                      )
                    else
                      ..._availableToAdd.map((s) {
                        final busy = _adding.contains(s.id);
                        final price = _priceLabel(s.priceValue);
                        final dur = s.durationMinutes;
                        final sub = <String>[];
                        if (dur != null) sub.add('$dur мин');
                        if (price.isNotEmpty) sub.add(price);
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Card(
                            margin: EdgeInsets.zero,
                            clipBehavior: Clip.antiAlias,
                            shape: profileCardShape(cs),
                            child: ListTile(
                              title: Text(s.name),
                              subtitle: sub.isEmpty
                                  ? null
                                  : Text(
                                      sub.join(' · '),
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: cs.onSurfaceVariant,
                                      ),
                                    ),
                              trailing: busy
                                  ? const SizedBox(
                                      width: 28,
                                      height: 28,
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    )
                                  : FilledButton.tonal(
                                      onPressed: () => _add(s),
                                      child: const Text('Добавить'),
                                    ),
                            ),
                          ),
                        );
                      }),
                  ],
                ],
              ),
            ),
    );
  }
}
