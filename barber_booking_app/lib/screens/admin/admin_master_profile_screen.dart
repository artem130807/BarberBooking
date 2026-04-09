import 'package:barber_booking_app/models/salon_models/response/salon_navigation_response.dart';
import 'package:barber_booking_app/utils/api_media_url.dart';
import 'package:barber_booking_app/providers/auth_providers/auth_provider.dart';
import 'package:barber_booking_app/providers/master_providers/admin_master_profile_provider.dart';
import 'package:barber_booking_app/widgets/error_widget.dart';
import 'package:barber_booking_app/widgets/loading_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

/// Аргументы маршрута [`/admin_master_profile`].
class AdminMasterProfileArgs {
  const AdminMasterProfileArgs({
    required this.masterId,
    this.previewName,
  });

  final String masterId;
  final String? previewName;
}

/// Просмотр профиля мастера для администратора ([DtoMasterProfileInfoForAdmin] / GetMasterProfileByIdForAdmin).
class AdminMasterProfileScreen extends StatefulWidget {
  const AdminMasterProfileScreen({
    super.key,
    required this.masterId,
    this.previewName,
  });

  final String masterId;
  final String? previewName;

  @override
  State<AdminMasterProfileScreen> createState() =>
      _AdminMasterProfileScreenState();
}

class _AdminMasterProfileScreenState extends State<AdminMasterProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    final token = context.read<AuthProvider>().token;
    await context.read<AdminMasterProfileProvider>().load(widget.masterId, token);
  }

  void _copy(BuildContext context, String label, String value) {
    Clipboard.setData(ClipboardData(text: value));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label скопировано'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _openSalon(BuildContext context, String? salonId) {
    if (salonId == null || salonId.isEmpty) return;
    Navigator.pushNamed(context, '/admin_salon_detail', arguments: salonId);
  }

  String _initials(String? name) {
    if (name == null || name.trim().isEmpty) return '?';
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.length >= 2 ? name.substring(0, 2).toUpperCase() : name[0].toUpperCase();
  }

  String _salonAddressLine(SalonNavigationResponse? nav) {
    final a = nav?.Address;
    if (a == null) return '';
    final parts = <String>[
      if (a.Street != null && a.Street!.isNotEmpty) a.Street!,
      if (a.City != null && a.City!.isNotEmpty) a.City!,
    ];
    return parts.join(', ');
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final prov = context.watch<AdminMasterProfileProvider>();
    final titleName = widget.previewName ?? prov.master?.userName;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          titleName != null && titleName.isNotEmpty ? titleName : 'Мастер',
        ),
      ),
      body: Builder(
        builder: (context) {
          if (prov.isLoading && prov.master == null) {
            return const Center(
              child: LoadingIndicator(message: 'Загрузка профиля...'),
            );
          }
          if (prov.errorMessage != null && prov.master == null) {
            return Center(
              child: ErrorWidgetCustom(
                message: prov.errorMessage!,
                onRetry: _load,
              ),
            );
          }

          final m = prov.master;
          if (m == null) {
            return Center(
              child: Text(
                'Нет данных',
                style: TextStyle(color: cs.onSurfaceVariant),
              ),
            );
          }

          final addressLine = _salonAddressLine(m.salonNavigation);
          final idStr = m.id ?? widget.masterId;
          final createdStr = m.createdAt != null
              ? DateFormat('dd.MM.yyyy, HH:mm').format(m.createdAt!.toLocal())
              : null;
          final avatarResolved = resolveApiMediaUrl(m.avatarUrl);

          return RefreshIndicator(
            onRefresh: _load,
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Center(
                  child: CircleAvatar(
                    radius: 56,
                    backgroundColor: cs.primaryContainer,
                    backgroundImage: avatarResolved != null
                        ? NetworkImage(avatarResolved)
                        : null,
                    child: avatarResolved == null
                        ? Text(
                            _initials(m.userName),
                            style: TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.w600,
                              color: cs.onPrimaryContainer,
                            ),
                          )
                        : null,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  m.userName ?? 'Без имени',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                if (m.specialization != null &&
                    m.specialization!.trim().isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    m.specialization!,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                  ),
                ],
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.star_rounded, color: cs.primary, size: 22),
                    const SizedBox(width: 6),
                    Text(
                      '${(m.rating ?? 0).toStringAsFixed(1)} · ${m.ratingCount ?? 0} оценок',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _InfoCard(
                  cs: cs,
                  child: Column(
                    children: [
                      _InfoTile(
                        icon: Icons.person_outline_rounded,
                        label: 'Имя',
                        value: m.userName,
                        onCopy: m.userName != null && m.userName!.isNotEmpty
                            ? () => _copy(context, 'Имя', m.userName!)
                            : null,
                      ),
                      Divider(height: 1, color: cs.outlineVariant),
                      _InfoTile(
                        icon: Icons.phone_outlined,
                        label: 'Телефон',
                        value: m.masterPhone,
                        onCopy: m.masterPhone != null &&
                                m.masterPhone!.trim().isNotEmpty
                            ? () => _copy(
                                  context,
                                  'Телефон',
                                  m.masterPhone!.trim(),
                                )
                            : null,
                      ),
                      Divider(height: 1, color: cs.outlineVariant),
                      _InfoTile(
                        icon: Icons.email_outlined,
                        label: 'Email',
                        value: m.masterEmail,
                        onCopy: m.masterEmail != null &&
                                m.masterEmail!.trim().isNotEmpty
                            ? () => _copy(
                                  context,
                                  'Email',
                                  m.masterEmail!.trim(),
                                )
                            : null,
                      ),
                      Divider(height: 1, color: cs.outlineVariant),
                      _InfoTile(
                        icon: Icons.work_outline_rounded,
                        label: 'Специализация',
                        value: m.specialization,
                        onCopy: m.specialization != null &&
                                m.specialization!.trim().isNotEmpty
                            ? () => _copy(
                                  context,
                                  'Специализация',
                                  m.specialization!.trim(),
                                )
                            : null,
                      ),
                      if (m.salonNavigation != null) ...[
                        Divider(height: 1, color: cs.outlineVariant),
                        _SalonNavTile(
                          nav: m.salonNavigation!,
                          addressLine: addressLine,
                          onOpenSalon: () =>
                              _openSalon(context, m.salonNavigation!.Id),
                          onCopyName: m.salonNavigation!.SalonName != null &&
                                  m.salonNavigation!.SalonName!.isNotEmpty
                              ? () => _copy(
                                    context,
                                    'Название салона',
                                    m.salonNavigation!.SalonName!,
                                  )
                              : null,
                          onCopyAddress: addressLine.isNotEmpty
                              ? () => _copy(
                                    context,
                                    'Адрес',
                                    addressLine,
                                  )
                              : null,
                        ),
                      ],
                      if (m.bio != null && m.bio!.trim().isNotEmpty) ...[
                        Divider(height: 1, color: cs.outlineVariant),
                        _InfoTile(
                          icon: Icons.article_outlined,
                          label: 'О себе',
                          value: m.bio,
                          onCopy: () =>
                              _copy(context, 'О себе', m.bio!.trim()),
                        ),
                      ],
                      if (createdStr != null) ...[
                        Divider(height: 1, color: cs.outlineVariant),
                        _InfoTile(
                          icon: Icons.event_available_outlined,
                          label: 'В системе с',
                          value: createdStr,
                          onCopy: () => _copy(context, 'Дата', createdStr),
                        ),
                      ],
                      Divider(height: 1, color: cs.outlineVariant),
                      _InfoTile(
                        icon: Icons.badge_outlined,
                        label: 'ID',
                        value: idStr,
                        dense: true,
                        onCopy: idStr.isNotEmpty
                            ? () => _copy(context, 'ID', idStr)
                            : null,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.cs,
    required this.child,
  });

  final ColorScheme cs;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: cs.surfaceContainerHighest,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: cs.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: child,
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
    this.dense = false,
    this.onCopy,
  });

  final IconData icon;
  final String label;
  final String? value;
  final bool dense;
  final VoidCallback? onCopy;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final display = value != null && value!.isNotEmpty ? value! : '—';
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 16,
        vertical: dense ? 10 : 14,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 22, color: cs.primary),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: cs.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 4),
                SelectableText(
                  display,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
          ),
          if (onCopy != null)
            IconButton(
              tooltip: 'Копировать',
              icon: const Icon(Icons.copy_rounded, size: 20),
              onPressed: onCopy,
              visualDensity: VisualDensity.compact,
            ),
        ],
      ),
    );
  }
}

/// Салон: переход на [`/admin_salon_detail`], копирование названия и адреса.
class _SalonNavTile extends StatelessWidget {
  const _SalonNavTile({
    required this.nav,
    required this.addressLine,
    required this.onOpenSalon,
    this.onCopyName,
    this.onCopyAddress,
  });

  final SalonNavigationResponse nav;
  final String addressLine;
  final VoidCallback onOpenSalon;
  final VoidCallback? onCopyName;
  final VoidCallback? onCopyAddress;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final name = nav.SalonName ?? '—';
    final canNavigate = nav.Id != null && nav.Id!.isNotEmpty;
    final salonPhoto = resolveApiMediaUrl(nav.MainPhotoUrl);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.store_mall_directory_outlined,
              size: 22, color: cs.primary),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Салон',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: cs.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                if (salonPhoto != null) ...[
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: AspectRatio(
                      aspectRatio: 16 / 9,
                      child: Image.network(
                        salonPhoto,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => ColoredBox(
                          color: cs.surfaceContainerHighest,
                          child: Icon(
                            Icons.storefront_outlined,
                            size: 40,
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 6),
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: canNavigate ? onOpenSalon : null,
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              name,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w600),
                            ),
                          ),
                          if (canNavigate)
                            Icon(
                              Icons.chevron_right_rounded,
                              size: 22,
                              color: cs.onSurfaceVariant,
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
                if (addressLine.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  SelectableText(
                    addressLine,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                  ),
                ],
              ],
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (onCopyName != null)
                IconButton(
                  tooltip: 'Копировать название',
                  icon: const Icon(Icons.copy_rounded, size: 20),
                  onPressed: onCopyName,
                  visualDensity: VisualDensity.compact,
                ),
              if (onCopyAddress != null)
                IconButton(
                  tooltip: 'Копировать адрес',
                  icon: const Icon(Icons.copy_all_outlined, size: 20),
                  onPressed: onCopyAddress,
                  visualDensity: VisualDensity.compact,
                ),
            ],
          ),
        ],
      ),
    );
  }
}
