import 'package:barber_booking_app/models/master_interface_models/response/get_master_appointment_info_response.dart';
import 'package:barber_booking_app/providers/auth_providers/auth_provider.dart';
import 'package:barber_booking_app/screens/master/master_navigation.dart';
import 'package:barber_booking_app/services/master_services/master_appointment_detail_service.dart';
import 'package:barber_booking_app/utils/appointment_status_normalize.dart';
import 'package:barber_booking_app/utils/appointment_time_format.dart';
import 'package:barber_booking_app/widgets/loading_indicator.dart';
import 'package:barber_booking_app/widgets/phone_tap_bar.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class MasterAppointmentDetailScreen extends StatefulWidget {
  const MasterAppointmentDetailScreen({
    super.key,
    required this.appointmentId,
    this.masterNavTab = MasterNav.appointments,
  });

  final String appointmentId;
  /// Вкладка shell, с которой логично вернуться (подсветка нижней панели).
  final int masterNavTab;

  @override
  State<MasterAppointmentDetailScreen> createState() =>
      _MasterAppointmentDetailScreenState();
}

class _MasterAppointmentDetailScreenState
    extends State<MasterAppointmentDetailScreen> {
  final MasterAppointmentDetailService _service =
      MasterAppointmentDetailService();
  GetMasterAppointmentInfoResponse? _data;
  bool _loading = true;
  bool _cancelling = false;
  bool _completing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    final token = context.read<AuthProvider>().token;
    setState(() => _loading = true);
    final r = await _service.fetchById(
      token: token,
      appointmentId: widget.appointmentId,
    );
    if (!mounted) return;
    setState(() {
      _data = r;
      _loading = false;
    });
  }

  String _statusRu(String? s) {
    switch (s) {
      case 'Confirmed':
        return 'Подтверждена';
      case 'Completed':
        return 'Завершена';
      case 'Cancelled':
        return 'Отменена';
      default:
        return s ?? '—';
    }
  }

  bool _canCancelOrComplete(String? status) => status == 'Confirmed';

  Future<void> _complete() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Завершить запись?'),
        content: const Text(
          'Запись будет отмечена как выполненная. Вы и клиент получите уведомление.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Назад'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Завершить'),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    final token = context.read<AuthProvider>().token;
    setState(() => _completing = true);
    final result = await _service.completeAppointment(
      token: token,
      appointmentId: widget.appointmentId,
    );
    if (!mounted) return;
    setState(() => _completing = false);
    if (result.ok) {
      // Один канал обратной связи: push приходит по SignalR (см. CompletedStatusAppointmentHandler).
      Navigator.of(context).pop(true);
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(result.errorMessage ?? 'Не удалось завершить запись'),
      ),
    );
  }

  Future<void> _cancel() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Отменить запись?'),
        content: const Text('Клиент получит уведомление об отмене.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Нет'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(ctx).colorScheme.error,
              foregroundColor: Theme.of(ctx).colorScheme.onError,
            ),
            child: const Text('Отменить запись'),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    final token = context.read<AuthProvider>().token;
    setState(() => _cancelling = true);
    final success = await _service.cancelAppointment(
      token: token,
      appointmentId: widget.appointmentId,
    );
    if (!mounted) return;
    setState(() => _cancelling = false);
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Запись отменена')),
      );
      Navigator.of(context).pop(true);
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Не удалось отменить запись')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final df = DateFormat('dd.MM.yyyy');
    final phone = _data?.dtoUsersNavigation?.dtoPhone?.Number.trim();

    return MasterScreenScaffold(
      selectedTabIndex: widget.masterNavTab,
      appBar: AppBar(
        title: const Text('Запись'),
      ),
      body: _loading
          ? const Center(child: LoadingIndicator(message: 'Загрузка…'))
          : _data == null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Не удалось загрузить запись',
                        style: TextStyle(color: cs.onSurfaceVariant),
                      ),
                      const SizedBox(height: 16),
                      FilledButton.tonal(
                        onPressed: _load,
                        child: const Text('Повторить'),
                      ),
                    ],
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    _section(
                      context,
                      'Клиент',
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(Icons.person_outline, color: cs.primary),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  _data!.dtoUsersNavigation?.Name ?? 'Клиент',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.w700,
                                      ),
                                ),
                              ),
                            ],
                          ),
                          if (phone != null && phone.isNotEmpty) ...[
                            const SizedBox(height: 10),
                            Padding(
                              padding: const EdgeInsets.only(left: 36),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(top: 2),
                                    child: Icon(
                                      Icons.phone_outlined,
                                      size: 18,
                                      color: cs.onSurfaceVariant,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: PhoneTapBar(
                                      phone: phone,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(
                                            color: cs.onSurfaceVariant,
                                          ),
                                      dense: true,
                                      showDialIcon: false,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    _section(
                      context,
                      'Услуга',
                      Text(
                        _data!.dtoServicesNavigation?.Name ?? '—',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ),
                    if (_data!.dtoServicesNavigation?.Price?.Value != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        '${_data!.dtoServicesNavigation!.Price!.Value!.toStringAsFixed(0)} ₽',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 18,
                          color: cs.primary,
                        ),
                      ),
                    ],
                    const SizedBox(height: 4),
                    const SizedBox(height: 16),
                    _section(
                      context,
                      'Салон',
                      Text(
                        _data!.SalonName ?? '—',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _section(
                      context,
                      'Дата и время',
                      Text(
                        _data!.AppointmentDate != null
                            ? '${df.format(_data!.AppointmentDate!.toLocal())} · '
                                '${formatAppointmentTimeHm(_data!.StartTime)}–'
                                '${formatAppointmentTimeHm(_data!.EndTime)}'
                            : '—',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _section(
                      context,
                      'Статус',
                      Chip(
                        label: Text(_statusRu(_data!.Status)),
                      ),
                    ),
                    if (_data!.ClientNotes != null &&
                        _data!.ClientNotes!.trim().isNotEmpty) ...[
                      const SizedBox(height: 16),
                      _section(
                        context,
                        'Комментарий клиента',
                        Text(
                          _data!.ClientNotes!,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    ],
                    const SizedBox(height: 32),
                    if (_canCancelOrComplete(_data!.Status)) ...[
                      FilledButton.icon(
                        onPressed: _completing ? null : _complete,
                        icon: _completing
                            ? SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: cs.onPrimary,
                                ),
                              )
                            : const Icon(Icons.check_circle_outline_rounded),
                        label: Text(
                          _completing ? 'Завершение…' : 'Завершить запись',
                        ),
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            vertical: 14,
                            horizontal: 20,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        onPressed: _cancelling ? null : _cancel,
                        icon: _cancelling
                            ? SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: cs.error,
                                ),
                              )
                            : Icon(Icons.cancel_outlined, color: cs.error),
                        label: Text(
                          _cancelling ? 'Отмена…' : 'Отменить запись',
                          style: TextStyle(color: cs.error),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: cs.error.withValues(alpha: 0.6)),
                          padding: const EdgeInsets.symmetric(
                            vertical: 14,
                            horizontal: 20,
                          ),
                        ),
                      ),
                    ] else if (appointmentStatusIsTerminal(_data!.Status)) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: cs.surfaceContainerHighest.withValues(
                            alpha: 0.65,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: cs.outline.withValues(alpha: 0.25),
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              _data!.Status == 'Completed'
                                  ? Icons.task_alt_rounded
                                  : Icons.event_busy_outlined,
                              color: cs.onSurfaceVariant,
                              size: 22,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _data!.Status == 'Completed'
                                    ? 'Запись завершена. Завершить или отменить её снова нельзя.'
                                    : 'Запись отменена. Действия с ней недоступны.',
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(
                                      color: cs.onSurfaceVariant,
                                      height: 1.35,
                                    ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
    );
  }

  Widget _section(BuildContext context, String title, Widget child) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: cs.onSurfaceVariant,
            letterSpacing: 0.2,
          ),
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}
