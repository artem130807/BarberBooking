import 'package:barber_booking_app/models/service_models/request/create_service_request.dart';
import 'package:barber_booking_app/models/service_models/request/update_service_request.dart';
import 'package:barber_booking_app/models/service_models/response/service_admin_list_item.dart';
import 'package:barber_booking_app/providers/auth_providers/auth_provider.dart';
import 'package:barber_booking_app/providers/service_providers/admin_salon_services_provider.dart';
import 'package:barber_booking_app/widgets/error_widget.dart';
import 'package:barber_booking_app/widgets/loading_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class AdminSalonServicesScreen extends StatefulWidget {
  const AdminSalonServicesScreen({super.key, required this.salonId});

  final String salonId;

  @override
  State<AdminSalonServicesScreen> createState() =>
      _AdminSalonServicesScreenState();
}

class _AdminSalonServicesScreenState extends State<AdminSalonServicesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    final token = context.read<AuthProvider>().token;
    await context.read<AdminSalonServicesProvider>().load(widget.salonId, token);
  }

  Future<void> _openCreate() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => _ServiceFormDialog(
        hostContext: context,
        salonId: widget.salonId,
        title: 'Новая услуга',
      ),
    );
    if (ok == true && mounted) await _load();
  }

  Future<void> _openEdit(ServiceAdminListItem item) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => _ServiceFormDialog(
        hostContext: context,
        salonId: widget.salonId,
        title: 'Редактирование',
        existing: item,
      ),
    );
    if (ok == true && mounted) await _load();
  }

  Future<void> _confirmDelete(ServiceAdminListItem item) async {
    final id = item.Id;
    if (id == null || id.isEmpty) return;
    final go = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Удалить услугу?'),
        content: Text('«${item.Name ?? ''}» будет удалена.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Отмена'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Удалить'),
          ),
        ],
      ),
    );
    if (go != true || !mounted) return;
    final token = context.read<AuthProvider>().token;
    final prov = context.read<AdminSalonServicesProvider>();
    final ok = await prov.deleteService(id, token);
    if (mounted && !ok && prov.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(prov.errorMessage!)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final money = NumberFormat('#0.##', 'ru_RU');
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Услуги салона')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openCreate,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Услуга'),
      ),
      body: Consumer<AdminSalonServicesProvider>(
        builder: (context, prov, _) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (prov.errorMessage != null && mounted) {
              prov.showApiError(context, prov.errorMessage);
            }
          });

          if (prov.isLoading && prov.items.isEmpty) {
            return const Center(
              child: LoadingIndicator(message: 'Загрузка услуг...'),
            );
          }

          if (prov.errorMessage != null && prov.items.isEmpty) {
            return Center(
              child: ErrorWidgetCustom(
                message: prov.errorMessage!,
                onRetry: _load,
              ),
            );
          }

          if (prov.items.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.content_cut_rounded,
                      size: 48, color: cs.onSurfaceVariant),
                  const SizedBox(height: 12),
                  const Text('Услуг пока нет'),
                  const SizedBox(height: 8),
                  FilledButton.tonal(
                    onPressed: _openCreate,
                    child: const Text('Добавить'),
                  ),
                ],
              ),
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                child: Text(
                  'Всего: ${prov.serverCount}',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                ),
              ),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _load,
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 88),
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
                                    child: const Text('Ещё'),
                                  ),
                          ),
                        );
                      }
                      final e = prov.items[i];
                      final price = e.Price?.Value;
                      final active = e.IsActive != false;
                      return Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        elevation: 0,
                        color: cs.surfaceContainerHighest.withValues(alpha: 0.45),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: cs.outline.withValues(alpha: 0.1),
                          ),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          title: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  e.Name ?? '—',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              if (!active)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: cs.errorContainer,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    'Выкл',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: cs.onErrorContainer,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (e.Description != null &&
                                  e.Description!.isNotEmpty)
                                Text(
                                  e.Description!,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              Text(
                                '${e.DurationMinutes ?? 0} мин · ${price != null ? '${money.format(price)} ₽' : '—'}',
                                style: TextStyle(
                                  color: cs.onSurfaceVariant,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                          trailing: PopupMenuButton<String>(
                            onSelected: (v) {
                              if (v == 'edit') _openEdit(e);
                              if (v == 'del') _confirmDelete(e);
                            },
                            itemBuilder: (ctx) => [
                              const PopupMenuItem(
                                value: 'edit',
                                child: Text('Изменить'),
                              ),
                              const PopupMenuItem(
                                value: 'del',
                                child: Text('Удалить'),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ServiceFormDialog extends StatefulWidget {
  const _ServiceFormDialog({
    required this.hostContext,
    required this.salonId,
    required this.title,
    this.existing,
  });

  final BuildContext hostContext;
  final String salonId;
  final String title;
  final ServiceAdminListItem? existing;

  @override
  State<_ServiceFormDialog> createState() => _ServiceFormDialogState();
}

class _ServiceFormDialogState extends State<_ServiceFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _desc;
  late final TextEditingController _duration;
  late final TextEditingController _price;
  late final TextEditingController _photo;
  bool _isActive = true;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _name = TextEditingController(text: e?.Name ?? '');
    _desc = TextEditingController(text: e?.Description ?? '');
    _duration = TextEditingController(
      text: e?.DurationMinutes?.toString() ?? '30',
    );
    _price = TextEditingController(
      text: e?.Price?.Value != null ? '${e!.Price!.Value}' : '',
    );
    _photo = TextEditingController(text: e?.PhotoUrl ?? '');
    _isActive = e?.IsActive != false;
  }

  @override
  void dispose() {
    _name.dispose();
    _desc.dispose();
    _duration.dispose();
    _price.dispose();
    _photo.dispose();
    super.dispose();
  }

  double? _parsePrice(String s) {
    final t = s.trim().replaceAll(',', '.');
    return double.tryParse(t);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final token = Provider.of<AuthProvider>(widget.hostContext, listen: false)
        .token;
    final prov = Provider.of<AdminSalonServicesProvider>(
      widget.hostContext,
      listen: false,
    );
    final duration = int.tryParse(_duration.text.trim());
    final price = _parsePrice(_price.text);
    if (duration == null || duration <= 0) return;
    if (price == null || price < 0) return;

    final existing = widget.existing;
    if (existing?.Id != null) {
      final body = UpdateServiceRequest(
        name: _name.text.trim(),
        description: _desc.text.trim().isEmpty ? null : _desc.text.trim(),
        durationMinutes: duration,
        priceValue: price,
        photo: _photo.text.trim().isEmpty ? null : _photo.text.trim(),
        isActive: _isActive,
      );
      final ok = await prov.updateService(existing!.Id!, body, token);
      if (mounted) Navigator.pop(context, ok);
      return;
    }

    final body = CreateServiceRequest(
      salonId: widget.salonId,
      name: _name.text.trim(),
      description: _desc.text.trim().isEmpty ? null : _desc.text.trim(),
      durationMinutes: duration,
      priceValue: price,
      photoUrl: _photo.text.trim().isEmpty ? null : _photo.text.trim(),
    );
    final ok = await prov.createService(body, token);
    if (mounted) Navigator.pop(context, ok);
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existing?.Id != null;
    return AlertDialog(
      title: Text(widget.title),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _name,
                decoration: const InputDecoration(labelText: 'Название'),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Укажите название' : null,
              ),
              TextFormField(
                controller: _desc,
                decoration: const InputDecoration(labelText: 'Описание'),
                maxLines: 2,
              ),
              TextFormField(
                controller: _duration,
                decoration: const InputDecoration(labelText: 'Длительность (мин)'),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (v) {
                  final n = int.tryParse(v?.trim() ?? '');
                  if (n == null || n <= 0) return 'Укажите минуты';
                  return null;
                },
              ),
              TextFormField(
                controller: _price,
                decoration: const InputDecoration(labelText: 'Цена (₽)'),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                validator: (v) {
                  final p = _parsePrice(v ?? '');
                  if (p == null || p < 0) return 'Укажите цену';
                  return null;
                },
              ),
              TextFormField(
                controller: _photo,
                decoration: const InputDecoration(
                  labelText: 'URL фото (необязательно)',
                ),
              ),
              if (isEdit)
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Активна'),
                  value: _isActive,
                  onChanged: (v) => setState(() => _isActive = v),
                ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Отмена'),
        ),
        FilledButton(
          onPressed: _submit,
          child: Text(isEdit ? 'Сохранить' : 'Создать'),
        ),
      ],
    );
  }
}
