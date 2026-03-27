import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:barber_booking_app/providers/auth_providers/auth_provider.dart';
import 'package:barber_booking_app/providers/appointment_providers/get_appointment_client_provider.dart';
import 'package:barber_booking_app/models/appointment_models/response/get_appointment_client_response.dart';
import 'package:barber_booking_app/providers/appointment_providers/delete_appointment_provider.dart';
import 'package:barber_booking_app/widgets/loading_indicator.dart';
import 'package:barber_booking_app/widgets/error_widget.dart';
import 'package:barber_booking_app/utils/appointment_status_ru.dart';

class AppointmentDetailScreen extends StatefulWidget {
  final String appointmentId;

  const AppointmentDetailScreen({super.key, required this.appointmentId});

  @override
  State<AppointmentDetailScreen> createState() => _AppointmentDetailScreenState();
}

class _AppointmentDetailScreenState extends State<AppointmentDetailScreen> {
  @override
  void initState() {
    super.initState();
    _loadAppointment();
  }

  void _loadAppointment() {
    final token = Provider.of<AuthProvider>(context, listen: false).token;
    if (token == null) return;
    Provider.of<GetAppointmentClientProvider>(context, listen: false)
        .getAppointment(widget.appointmentId, token);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GetAppointmentClientProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          appBar: AppBar(title: const Text('Детали записи')),
          body: _buildBody(provider),
        );
      },
    );
  }

  Widget _buildBody(GetAppointmentClientProvider provider) {
    if (provider.isLoading && provider.appointment == null) {
      return const LoadingIndicator(message: 'Загрузка...');
    }

    if (provider.errorMessage != null && provider.appointment == null) {
      return ErrorWidgetCustom(
        message: provider.errorMessage!,
        onRetry: _loadAppointment,
      );
    }

    final a = provider.appointment;
    if (a == null) {
      return const Center(child: Text('Запись не найдена'));
    }

    return _buildContent(a);
  }

  Widget _buildContent(GetAppointmentClientResponse a) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatusBanner(a.Status, cs),
          const SizedBox(height: 24),
          _buildSection(
            icon: Icons.content_cut,
            title: 'Услуга',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  a.dtoServicesNavigation?.Name ?? 'Не указана',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: cs.onSurface,
                  ),
                ),
                if (a.dtoServicesNavigation?.Price?.Value != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    '${a.dtoServicesNavigation!.Price!.Value!.toStringAsFixed(0)} ₽',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: cs.primary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),
          _buildSection(
            icon: Icons.calendar_today_outlined,
            title: 'Дата и время',
            child: Row(
              children: [
                _buildInfoChip(
                  Icons.calendar_today_outlined,
                  _formatDate(a.AppointmentDate),
                  cs,
                ),
                const SizedBox(width: 12),
                _buildInfoChip(
                  Icons.schedule,
                  '${_formatTime(a.StartTime)} – ${_formatTime(a.EndTime)}',
                  cs,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _buildSection(
            icon: Icons.store_outlined,
            title: 'Салон',
            child: _buildNavigationTile(
              icon: Icons.store_outlined,
              label: a.SalonName ?? 'Не указан',
              onTap: a.SalonId != null
                  ? () => Navigator.pushNamed(context, '/salon_screen', arguments: a.SalonId)
                  : null,
            ),
          ),
          const SizedBox(height: 16),
          _buildSection(
            icon: Icons.person_outline,
            title: 'Мастер',
            child: _buildNavigationTile(
              icon: Icons.person_outline,
              label: a.dtoMasterProfileNavigation?.MasterName ?? 'Не указан',
              onTap: a.dtoMasterProfileNavigation?.Id != null
                  ? () => Navigator.pushNamed(
                        context,
                        '/master_detail',
                        arguments: a.dtoMasterProfileNavigation!.Id,
                      )
                  : null,
            ),
          ),
          if (a.ClientNotes != null && a.ClientNotes!.isNotEmpty) ...[
            const SizedBox(height: 16),
            _buildSection(
              icon: Icons.notes,
              title: 'Заметка',
              child: Text(
                a.ClientNotes!,
                style: TextStyle(fontSize: 15, color: cs.onSurface, height: 1.4),
              ),
            ),
          ],
          if (_isCancellable(a.Status)) ...[
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: Consumer<DeleteAppointmentProvider>(
                builder: (context, deleteProvider, _) {
                  return OutlinedButton.icon(
                    onPressed: deleteProvider.isLoading
                        ? null
                        : () => _confirmCancel(a.Id),
                    icon: deleteProvider.isLoading
                        ? SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: cs.error,
                            ),
                          )
                        : Icon(Icons.cancel_outlined, color: cs.error),
                    label: Text(
                      deleteProvider.isLoading ? 'Отмена...' : 'Отменить запись',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: cs.error,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: cs.error),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  bool _isCancellable(String? status) {
    return status == 'Confirmed' || status == 'Pending';
  }

  Future<void> _confirmCancel(String? id) async {
    if (id == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        final cs = Theme.of(ctx).colorScheme;
        return AlertDialog(
          backgroundColor: cs.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text('Отменить запись?', style: TextStyle(color: cs.onSurface)),
          content: Text(
            'Вы уверены, что хотите отменить эту запись? Это действие нельзя отменить.',
            style: TextStyle(color: cs.onSurfaceVariant),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text('Нет', style: TextStyle(color: cs.onSurfaceVariant)),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text('Да, отменить', style: TextStyle(color: cs.error)),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) return;

    final deleteProvider = Provider.of<DeleteAppointmentProvider>(context, listen: false);
    final success = await deleteProvider.deleteAppointment(id);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Запись отменена')),
      );
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(deleteProvider.errorMessage ?? 'Не удалось отменить запись'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  Widget _buildStatusBanner(String? status, ColorScheme cs) {
    final statusLabel = _statusText(status);
    final color = _statusColor(status, cs);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Row(
        children: [
          Icon(_statusIcon(status), color: color, size: 22),
          const SizedBox(width: 10),
          Text(
            statusLabel,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required IconData icon,
    required String title,
    required Widget child,
  }) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cs.outline.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: cs.onSurfaceVariant),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: cs.onSurfaceVariant,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }

  Widget _buildNavigationTile({
    required IconData icon,
    required String label,
    VoidCallback? onTap,
  }) {
    final cs = Theme.of(context).colorScheme;
    final enabled = onTap != null;

    return Material(
      color: enabled ? cs.primary.withOpacity(0.12) : cs.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Icon(icon, size: 20, color: enabled ? cs.primary : cs.onSurfaceVariant),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: enabled ? cs.primary : cs.onSurfaceVariant,
                  ),
                ),
              ),
              if (enabled)
                Icon(Icons.chevron_right, size: 20, color: cs.primary),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text, ColorScheme cs) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: cs.onSurfaceVariant),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(fontSize: 14, color: cs.onSurface, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  String _formatTime(String? timeStr) {
    if (timeStr == null || timeStr.isEmpty) return '--:--';
    final parts = timeStr.split(':');
    if (parts.length >= 2) {
      return '${parts[0].padLeft(2, '0')}:${parts[1].padLeft(2, '0')}';
    }
    return timeStr;
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    return DateFormat('dd.MM.yyyy').format(date);
  }

  String _statusText(String? status) => appointmentStatusLabelRu(status);

  IconData _statusIcon(String? status) {
    switch (status) {
      case 'Pending':
      case 'Confirmed':
        return Icons.access_time_filled;
      case 'Completed':
        return Icons.check_circle;
      case 'Cancelled':
        return Icons.cancel;
      default:
        return Icons.info_outline;
    }
  }

  Color _statusColor(String? status, ColorScheme cs) {
    switch (status) {
      case 'Pending':
      case 'Confirmed':
        return cs.primary;
      case 'Completed':
        return const Color(0xFF4CAF50);
      case 'Cancelled':
        return cs.error;
      default:
        return cs.onSurfaceVariant;
    }
  }
}
