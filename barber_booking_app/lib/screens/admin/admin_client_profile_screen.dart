import 'package:barber_booking_app/providers/auth_providers/auth_provider.dart';
import 'package:barber_booking_app/providers/user_providers/get_user_profile_by_id_provider.dart';
import 'package:barber_booking_app/widgets/error_widget.dart';
import 'package:barber_booking_app/widgets/loading_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

/// Аргументы маршрута [`/admin_client_profile`].
class AdminClientProfileArgs {
  const AdminClientProfileArgs({
    required this.userId,
    this.previewName,
  });

  final String userId;
  final String? previewName;
}

class AdminClientProfileScreen extends StatefulWidget {
  const AdminClientProfileScreen({
    super.key,
    required this.userId,
    this.previewName,
  });

  final String userId;
  final String? previewName;

  @override
  State<AdminClientProfileScreen> createState() =>
      _AdminClientProfileScreenState();
}

class _AdminClientProfileScreenState extends State<AdminClientProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    final token = context.read<AuthProvider>().token;
    await context.read<GetUserProfileByIdProvider>().load(widget.userId, token);
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

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final prov = context.watch<GetUserProfileByIdProvider>();
    final titleName =
        widget.previewName ?? prov.profile?.name;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          titleName != null && titleName.isNotEmpty ? titleName : 'Клиент',
        ),
      ),
      body: Builder(
        builder: (context) {
          if (prov.isLoading && prov.profile == null) {
            return const Center(
              child: LoadingIndicator(message: 'Загрузка профиля...'),
            );
          }
          if (prov.errorMessage != null && prov.profile == null) {
            return Center(
              child: ErrorWidgetCustom(
                message: prov.errorMessage!,
                onRetry: _load,
              ),
            );
          }

          final p = prov.profile;
          if (p == null) {
            return Center(
              child: Text(
                'Нет данных',
                style: TextStyle(color: cs.onSurfaceVariant),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _load,
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Center(
                  child: CircleAvatar(
                    radius: 48,
                    backgroundColor: cs.primaryContainer,
                    child: Text(
                      _initials(p.name),
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w600,
                        color: cs.onPrimaryContainer,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  p.name ?? 'Без имени',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 24),
                _InfoCard(
                  cs: cs,
                  child: Column(
                    children: [
                      _InfoTile(
                        icon: Icons.email_outlined,
                        label: 'Email',
                        value: p.email,
                        onCopy: p.email != null && p.email!.isNotEmpty
                            ? () => _copy(context, 'Email', p.email!)
                            : null,
                      ),
                      Divider(height: 1, color: cs.outlineVariant),
                      _InfoTile(
                        icon: Icons.phone_outlined,
                        label: 'Телефон',
                        value: p.phone?.number,
                        onCopy: p.phone?.number != null &&
                                p.phone!.number!.isNotEmpty
                            ? () =>
                                _copy(context, 'Телефон', p.phone!.number!)
                            : null,
                      ),
                      Divider(height: 1, color: cs.outlineVariant),
                      _InfoTile(
                        icon: Icons.badge_outlined,
                        label: 'ID',
                        value: p.id,
                        dense: true,
                        onCopy: p.id != null && p.id!.isNotEmpty
                            ? () => _copy(context, 'ID', p.id!)
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

  String _initials(String? name) {
    if (name == null || name.trim().isEmpty) return '?';
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.length >= 2 ? name.substring(0, 2).toUpperCase() : name[0].toUpperCase();
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
