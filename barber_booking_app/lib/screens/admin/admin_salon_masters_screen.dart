import 'package:barber_booking_app/models/master_models/request/create_master_profile_admin_request.dart';
import 'package:barber_booking_app/models/master_models/response/master_profile_info_admin_response.dart';
import 'package:barber_booking_app/providers/auth_providers/auth_provider.dart';
import 'package:barber_booking_app/providers/master_providers/admin_salon_masters_provider.dart';
import 'package:barber_booking_app/widgets/error_widget.dart';
import 'package:barber_booking_app/widgets/loading_indicator.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

final _emailRe = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

class AdminSalonMastersScreen extends StatefulWidget {
  const AdminSalonMastersScreen({super.key, required this.salonId});

  final String salonId;

  @override
  State<AdminSalonMastersScreen> createState() =>
      _AdminSalonMastersScreenState();
}

class _AdminSalonMastersScreenState extends State<AdminSalonMastersScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    final token = context.read<AuthProvider>().token;
    await context.read<AdminSalonMastersProvider>().load(widget.salonId, token);
  }

  Future<void> _openCreate() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => _CreateMasterDialog(
        hostContext: context,
        salonId: widget.salonId,
      ),
    );
    if (ok == true && mounted) await _load();
  }

  Future<void> _confirmDelete(MasterProfileInfoAdminResponse m) async {
    final id = m.Id;
    if (id == null || id.isEmpty) return;
    final go = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Удалить мастера?'),
        content: Text(
          'Профиль «${m.UserName ?? id}» будет удалён.',
        ),
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
    final prov = context.read<AdminSalonMastersProvider>();
    final err = await prov.deleteMaster(id, token);
    if (mounted && err != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Мастера салона')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openCreate,
        icon: const Icon(Icons.person_add_rounded),
        label: const Text('Мастер'),
      ),
      body: Consumer<AdminSalonMastersProvider>(
        builder: (context, prov, _) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (prov.errorMessage != null && mounted) {
              prov.showApiError(context, prov.errorMessage);
            }
          });

          if (prov.isLoading && prov.items.isEmpty) {
            return const Center(
              child: LoadingIndicator(message: 'Загрузка...'),
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
                  Icon(Icons.person_outline_rounded,
                      size: 48, color: cs.onSurfaceVariant),
                  const SizedBox(height: 12),
                  const Text('Мастеров нет'),
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
                      final m = prov.items[i];
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
                          leading: CircleAvatar(
                            backgroundImage: m.AvatarUrl != null &&
                                    m.AvatarUrl!.isNotEmpty
                                ? NetworkImage(m.AvatarUrl!)
                                : null,
                            child: m.AvatarUrl == null || m.AvatarUrl!.isEmpty
                                ? Text(
                                    (m.UserName ?? '?').isNotEmpty
                                        ? m.UserName![0].toUpperCase()
                                        : '?',
                                  )
                                : null,
                          ),
                          title: Text(
                            m.UserName ?? '—',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Text(
                            [
                              if (m.Specialization != null &&
                                  m.Specialization!.isNotEmpty)
                                m.Specialization!,
                              if (m.Rating != null)
                                '${m.Rating!.toStringAsFixed(1)} ★ (${m.RatingCount ?? 0})',
                            ].join(' · '),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: IconButton(
                            icon: Icon(Icons.delete_outline_rounded,
                                color: cs.error),
                            onPressed: () => _confirmDelete(m),
                            tooltip: 'Удалить',
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

class _CreateMasterDialog extends StatefulWidget {
  const _CreateMasterDialog({
    required this.hostContext,
    required this.salonId,
  });

  final BuildContext hostContext;
  final String salonId;

  @override
  State<_CreateMasterDialog> createState() => _CreateMasterDialogState();
}

class _CreateMasterDialogState extends State<_CreateMasterDialog> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _bio = TextEditingController();
  final _spec = TextEditingController();
  final _avatar = TextEditingController();

  static const double _fieldGap = 16;

  @override
  void dispose() {
    _email.dispose();
    _bio.dispose();
    _spec.dispose();
    _avatar.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final token = Provider.of<AuthProvider>(widget.hostContext, listen: false)
        .token;
    final prov = Provider.of<AdminSalonMastersProvider>(
      widget.hostContext,
      listen: false,
    );
    final body = CreateMasterProfileAdminRequest(
      emailUser: _email.text.trim(),
      salonId: widget.salonId,
      bio: _bio.text.trim().isEmpty ? null : _bio.text.trim(),
      specialization: _spec.text.trim().isEmpty ? null : _spec.text.trim(),
      avatarUrl: _avatar.text.trim().isEmpty ? null : _avatar.text.trim(),
    );
    final err = await prov.createMaster(body, token);
    if (!mounted) return;
    if (err == null) {
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Новый мастер'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Укажите email зарегистрированного пользователя без профиля мастера.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                autocorrect: false,
                decoration: const InputDecoration(
                  labelText: 'Email пользователя',
                ),
                validator: (v) {
                  final t = v?.trim() ?? '';
                  if (t.isEmpty) return 'Введите email';
                  if (!_emailRe.hasMatch(t)) return 'Некорректный email';
                  return null;
                },
              ),
              const SizedBox(height: _fieldGap),
              TextFormField(
                controller: _spec,
                decoration: const InputDecoration(
                  labelText: 'Специализация',
                ),
              ),
              const SizedBox(height: _fieldGap),
              TextFormField(
                controller: _bio,
                decoration: const InputDecoration(labelText: 'О себе'),
                maxLines: 2,
              ),
              const SizedBox(height: _fieldGap),
              TextFormField(
                controller: _avatar,
                decoration: const InputDecoration(labelText: 'URL аватара'),
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
          child: const Text('Создать'),
        ),
      ],
    );
  }
}
