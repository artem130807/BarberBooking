import 'package:barber_booking_app/models/appointment_models/request/create_appointment_request.dart';
import 'package:barber_booking_app/models/master_models/response/get_master_response.dart';
import 'package:barber_booking_app/models/master_interface_models/response/master_service_for_booking.dart';
import 'package:barber_booking_app/models/time_slot_models/request/get_slots_request.dart';
import 'package:barber_booking_app/models/time_slot_models/response/get_available_slots.dart';
import 'package:barber_booking_app/providers/auth_providers/auth_provider.dart';
import 'package:barber_booking_app/screens/master/master_navigation.dart';
import 'package:barber_booking_app/services/master_services/master_manual_booking_service.dart';
import 'package:barber_booking_app/services/time_slot_services/get_slots_service.dart';
import 'package:barber_booking_app/utils/appointment_time_format.dart';
import 'package:barber_booking_app/widgets/loading_indicator.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class MasterManualBookingScreen extends StatefulWidget {
  const MasterManualBookingScreen({
    super.key,
    required this.profile,
    this.masterNavTab = MasterNav.today,
  });

  final GetMasterResponse profile;
  final int masterNavTab;

  @override
  State<MasterManualBookingScreen> createState() =>
      _MasterManualBookingScreenState();
}

class _MasterManualBookingScreenState extends State<MasterManualBookingScreen> {
  final MasterManualBookingService _api = MasterManualBookingService();
  final TextEditingController _notesController = TextEditingController();
  final GetSlotsService _slotsService = GetSlotsService();

  List<MasterServiceForBooking> _services = [];
  MasterServiceForBooking? _selectedService;
  DateTime _selectedDate = DateTime.now();
  List<GetAvailableSlots> _slots = [];
  GetAvailableSlots? _selectedSlot;
  bool _loadingServices = true;
  bool _loadingSlots = false;
  String? _servicesError;
  String? _slotsError;
  bool _submitting = false;

  String? get _salonId =>
      widget.profile.SalonNavigation?.Id ?? widget.profile.SalonId;
  String? get _masterId => widget.profile.Id;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadServices());
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadServices() async {
    final token = context.read<AuthProvider>().token;
    final mid = _masterId;
    if (mid == null || mid.isEmpty) {
      setState(() {
        _loadingServices = false;
        _servicesError = 'Профиль мастера не найден';
      });
      return;
    }
    if (_salonId == null || _salonId!.isEmpty) {
      setState(() {
        _loadingServices = false;
        _servicesError = 'Не указан салон в профиле';
      });
      return;
    }
    setState(() {
      _loadingServices = true;
      _servicesError = null;
    });
    final list = await _api.fetchServicesForBooking(
      masterProfileId: mid,
    );
    if (!mounted) return;
    setState(() {
      _services = list ?? [];
      _loadingServices = false;
      if (list == null) {
        _servicesError = 'Не удалось загрузить услуги';
      }
    });
  }

  String _durationQuery(int minutes) {
    final d = Duration(minutes: minutes);
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    final s = d.inSeconds.remainder(60);
    return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  Future<void> _loadSlots() async {
    final svc = _selectedService;
    final mid = _masterId;
    if (svc == null || mid == null || mid.isEmpty) {
      return;
    }
    setState(() {
      _loadingSlots = true;
      _slotsError = null;
      _selectedSlot = null;
      _slots = [];
    });
    final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);
    final request = GetSlotsRequest(
      DateTime: dateStr,
      ServiceDuration: _durationQuery(svc.durationMinutes),
    );
    try {
      final list = await _slotsService.getSlots(mid, request);
      if (!mounted) return;
      setState(() {
        _slots = list ?? [];
        _loadingSlots = false;
        if (_slots.isEmpty) {
          _slotsError = 'Нет свободных окон на выбранную дату';
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _slots = [];
        _loadingSlots = false;
        _slotsError = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  void _onServiceSelected(MasterServiceForBooking s) {
    setState(() {
      _selectedService = s;
      _selectedSlot = null;
    });
    _loadSlots();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final first = DateTime(now.year, now.month, now.day);
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: first,
      lastDate: first.add(const Duration(days: 365)),
    );
    if (picked == null || !mounted) return;
    setState(() => _selectedDate = picked);
    if (_selectedService != null) {
      _loadSlots();
    }
  }

  Future<void> _submit() async {
    final salonId = _salonId;
    final masterId = _masterId;
    final svc = _selectedService;
    final slot = _selectedSlot;
    if (salonId == null ||
        masterId == null ||
        svc == null ||
        slot == null ||
        slot.id == null ||
        slot.startTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Выберите услугу, дату и время')),
      );
      return;
    }
    final token = context.read<AuthProvider>().token;
    final notes = _notesController.text.trim();
    final request = CreateAppointmentRequest(
      SalonId: salonId,
      MasterId: masterId,
      ServiceId: svc.id,
      TimeSlotId: slot.id,
      ClientNotes: notes.isEmpty ? null : notes,
      StartTime: slot.startTime,
      AppointmentDate: DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
      ),
    );
    setState(() => _submitting = true);
    final err = await _api.createWithoutAppUser(request: request);
    if (!mounted) return;
    setState(() => _submitting = false);
    if (err != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(err)),
      );
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Запись создана')),
    );
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final df = DateFormat('dd.MM.yyyy');

    return MasterScreenScaffold(
      selectedTabIndex: widget.masterNavTab,
      appBar: AppBar(
        title: const Text('Запись вне приложения'),
      ),
      body: _loadingServices
          ? const Center(child: LoadingIndicator(message: 'Загрузка услуг…'))
          : _servicesError != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, size: 48, color: cs.error),
                        const SizedBox(height: 16),
                        Text(
                          _servicesError!,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        FilledButton.tonal(
                          onPressed: _loadServices,
                          child: const Text('Повторить'),
                        ),
                      ],
                    ),
                  ),
                )
              : _services.isEmpty
                  ? Center(
                      child: Text(
                        'Нет доступных услуг. Добавьте услуги в профиле.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: cs.onSurfaceVariant),
                      ),
                    )
                  : ListView(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                      children: [
                        Text(
                          'Услуга',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                color: cs.onSurfaceVariant,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        const SizedBox(height: 8),
                        ..._services.map((s) {
                          final selected = _selectedService?.id == s.id;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Material(
                              color: selected
                                  ? cs.primaryContainer
                                  : cs.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(12),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(12),
                                onTap: () => _onServiceSelected(s),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.content_cut,
                                        color: selected
                                            ? cs.onPrimaryContainer
                                            : cs.primary,
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              s.name,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 16,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              '${s.durationMinutes} мин · ${s.price?.Value != null ? '${s.price!.Value!.toStringAsFixed(0)} ₽' : '—'}',
                                              style: TextStyle(
                                                color: cs.onSurfaceVariant,
                                                fontSize: 13,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      if (selected)
                                        Icon(
                                          Icons.check_circle,
                                          color: cs.primary,
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                        if (_selectedService != null) ...[
                          const SizedBox(height: 24),
                          Row(
                            children: [
                              Text(
                                'Дата',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleSmall
                                    ?.copyWith(
                                      color: cs.onSurfaceVariant,
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                              const Spacer(),
                              TextButton.icon(
                                onPressed: _pickDate,
                                icon: const Icon(Icons.calendar_today, size: 18),
                                label: Text(df.format(_selectedDate)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Время',
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall
                                ?.copyWith(
                                  color: cs.onSurfaceVariant,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                          const SizedBox(height: 8),
                          if (_loadingSlots)
                            const Padding(
                              padding: EdgeInsets.all(24),
                              child: Center(
                                child: LoadingIndicator(
                                  message: 'Поиск свободного времени…',
                                ),
                              ),
                            )
                          else if (_slotsError != null && _slots.isEmpty)
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: cs.errorContainer.withValues(alpha: 0.35),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                _slotsError!,
                                style: TextStyle(color: cs.onErrorContainer),
                              ),
                            )
                          else if (_slots.isEmpty)
                            Text(
                              'Нет доступных интервалов',
                              style: TextStyle(color: cs.onSurfaceVariant),
                            )
                          else
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: _slots.map((slot) {
                                final sel = _selectedSlot != null &&
                                    _selectedSlot!.id == slot.id &&
                                    _selectedSlot!.startTime == slot.startTime;
                                final label =
                                    '${formatAppointmentTimeHm(slot.startTime)} — ${formatAppointmentTimeHm(slot.endTime)}';
                                return ChoiceChip(
                                  label: Text(label),
                                  selected: sel,
                                  onSelected: (_) {
                                    setState(() => _selectedSlot = slot);
                                  },
                                );
                              }).toList(),
                            ),
                          const SizedBox(height: 24),
                          Text(
                            'Комментарий (необязательно)',
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall
                                ?.copyWith(
                                  color: cs.onSurfaceVariant,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _notesController,
                            maxLines: 3,
                            decoration: const InputDecoration(
                              hintText: 'Например: звонок, имя клиента',
                              border: OutlineInputBorder(),
                              alignLabelWithHint: true,
                            ),
                          ),
                          const SizedBox(height: 28),
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton(
                              onPressed: _submitting ? null : _submit,
                              child: _submitting
                                  ? const SizedBox(
                                      height: 22,
                                      width: 22,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Text('Создать запись'),
                            ),
                          ),
                        ],
                      ],
                    ),
    );
  }
}
