import 'package:barber_booking_app/screens/admin/admin_master_profile_screen.dart';
import 'package:barber_booking_app/utils/admin_last_salon_storage.dart';
import 'package:barber_booking_app/providers/admin_top_masters_provider.dart';
import 'package:barber_booking_app/providers/auth_providers/auth_provider.dart';
import 'package:barber_booking_app/providers/salon_providers/get_salons_admin_provider.dart';
import 'package:barber_booking_app/utils/api_media_url.dart';
import 'package:barber_booking_app/widgets/error_widget.dart';
import 'package:barber_booking_app/widgets/loading_indicator.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AdminTopMastersScreen extends StatefulWidget {
  const AdminTopMastersScreen({super.key});

  @override
  State<AdminTopMastersScreen> createState() => _AdminTopMastersScreenState();
}

class _AdminTopMastersScreenState extends State<AdminTopMastersScreen> {
  String? _salonId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminTopMastersProvider>().clearList();
      _loadSalons();
    });
  }

  Future<void> _loadSalons() async {
    await context.read<GetSalonsAdminProvider>().load();
    if (!mounted) return;
    final saved = await AdminLastSalonStorage.read();
    if (!mounted) return;
    final list = context.read<GetSalonsAdminProvider>().asSalonListItems;
    if (saved != null &&
        saved.isNotEmpty &&
        list.any((e) => e.Id == saved)) {
      await _onSalonChanged(saved);
    } else {
      setState(() {});
    }
  }

  Future<void> _onSalonChanged(String? id) async {
    setState(() => _salonId = id);
    await AdminLastSalonStorage.write(id);
    if (id == null || id.isEmpty) return;
    if (!mounted) return;
    await context.read<AdminTopMastersProvider>().load(id);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Топ мастеров'),
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
                  'Рейтинг в салоне по числу отзывов и оценке.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                ),
                const SizedBox(height: 12),
                Consumer<GetSalonsAdminProvider>(
                  builder: (context, salons, _) {
                    final list = salons.asSalonListItems;
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
            child: Consumer<AdminTopMastersProvider>(
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
                        Icon(Icons.person_outline_rounded,
                            size: 48, color: cs.onSurfaceVariant),
                        const SizedBox(height: 12),
                        Text(
                          'В этом салоне пока нет мастеров',
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
                                      await prov.loadMore();
                                    },
                                    child: const Text('Загрузить ещё'),
                                  ),
                          ),
                        );
                      }
                      final m = prov.items[i];
                      final rank = i + 1;
                      final avatarResolved = resolveApiMediaUrl(m.AvatarUrl);
                      final initials = (m.UserName ?? '?').isNotEmpty
                          ? m.UserName![0].toUpperCase()
                          : '?';
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
                          onTap: () {
                            final id = m.Id;
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
                                previewName: m.UserName,
                              ),
                            );
                          },
                          leading: SizedBox(
                            width: 56,
                            height: 56,
                            child: Stack(
                              clipBehavior: Clip.none,
                              children: [
                                Positioned.fill(
                                  child: ClipOval(
                                    child: avatarResolved != null
                                        ? Image.network(
                                            avatarResolved,
                                            fit: BoxFit.cover,
                                            errorBuilder: (_, __, ___) =>
                                                ColoredBox(
                                              color: cs.surfaceContainerHighest,
                                              child: Center(
                                                child: Text(
                                                  initials,
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                    color: cs.onSurfaceVariant,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          )
                                        : ColoredBox(
                                            color: cs.surfaceContainerHighest,
                                            child: Center(
                                              child: Text(
                                                initials,
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                  color: cs.onSurfaceVariant,
                                                ),
                                              ),
                                            ),
                                          ),
                                  ),
                                ),
                                Positioned(
                                  left: -2,
                                  top: -2,
                                  child: CircleAvatar(
                                    radius: 12,
                                    backgroundColor: cs.primary,
                                    foregroundColor: cs.onPrimary,
                                    child: Text(
                                      '$rank',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
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
                                '${m.Rating!.toStringAsFixed(1)} ★ · отзывов: ${m.RatingCount ?? 0}',
                            ].join(' · '),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
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
