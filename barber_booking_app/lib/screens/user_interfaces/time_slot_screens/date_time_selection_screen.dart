import 'dart:async';

import 'package:barber_booking_app/providers/appointment_providers/%D1%81reate_appointment_provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:barber_booking_app/models/time_slot_models/response/get_available_slots.dart';
import 'package:barber_booking_app/providers/time_slot_providers/get_slots_provider.dart';
import 'package:barber_booking_app/models/time_slot_models/request/get_slots_request.dart';
import 'package:barber_booking_app/widgets/loading_indicator.dart';
import 'package:barber_booking_app/widgets/error_widget.dart';
import 'package:barber_booking_app/providers/auth_providers/auth_provider.dart';
import 'package:barber_booking_app/models/appointment_models/request/create_appointment_request.dart';

class DateTimeSelectionScreen extends StatefulWidget {
  final String masterName;
  final String masterId;
  final String serviceId;
  final String serviceName;
  final int? serviceDuration;
  final String salonId;

  const DateTimeSelectionScreen({
    super.key,
    required this.masterName,
    required this.masterId,
    required this.serviceId,
    required this.serviceName,
    required this.serviceDuration,
    required this.salonId,
  });

  @override
  State<DateTimeSelectionScreen> createState() => _DateTimeSelectionScreenState();
}

class _DateTimeSelectionScreenState extends State<DateTimeSelectionScreen> {
  static const Duration _loadDebounceDelay = Duration(milliseconds: 350);

  DateTime _selectedDate = DateTime.now();
  GetAvailableSlots? _selectedSlot;
  GetSlotsProvider? _slotsProvider;
  Timer? _loadDebounce;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final provider = context.read<GetSlotsProvider>();
      provider.resetForNewScreen();
      _slotsProvider = provider;
      _slotsProvider!.addListener(_onSlotsProviderChanged);
      _scheduleLoadSlotsForDate(_selectedDate, immediate: true);
    });
  }

  void _onSlotsProviderChanged() {
    if (!mounted) return;
    final p = _slotsProvider;
    final msg = p?.errorMessage;
    if (msg != null && msg.isNotEmpty) {
      p!.showApiError(context, msg);
    }
  }

  @override
  void dispose() {
    _loadDebounce?.cancel();
    _slotsProvider?.removeListener(_onSlotsProviderChanged);
    super.dispose();
  }

  void _scheduleLoadSlotsForDate(DateTime date, {bool immediate = false}) {
    _loadDebounce?.cancel();
    if (immediate) {
      _runLoadSlotsForDate(date);
      return;
    }
    _loadDebounce = Timer(_loadDebounceDelay, () {
      if (!mounted) return;
      _runLoadSlotsForDate(date);
    });
  }

  void _runLoadSlotsForDate(DateTime date) {
    final provider = Provider.of<GetSlotsProvider>(context, listen: false);
    final dateStr = DateFormat('yyyy-MM-dd').format(date);
    final minutes = (widget.serviceDuration != null && widget.serviceDuration! > 0)
        ? widget.serviceDuration!
        : 30;
    final duration = Duration(minutes: minutes);
    final hours = duration.inHours;
    final minutePart = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    final durationStr =
        '${hours.toString().padLeft(2, '0')}:${minutePart.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';

    final request = GetSlotsRequest(
      DateTime: dateStr,
      ServiceDuration: durationStr,
    );
    provider.getAvailableSlots(widget.masterId, request);
  }

  Future<void> _createAppointment() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final token = authProvider.token;
    if (token == null) return;

    final request = CreateAppointmentRequest(
      SalonId: widget.salonId,
      MasterId: widget.masterId,
      ServiceId: widget.serviceId,
      TimeSlotId: _selectedSlot!.id,
      ClientNotes: null,
      StartTime: _selectedSlot!.startTime,
      AppointmentDate: _selectedDate,
    );

    final createProvider = Provider.of<CreateAppointmentProvider>(context, listen: false);
    final success = await createProvider.createAppointment(request, token);
    
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Запись создана!')),
      );
      Navigator.popUntil(context, (route) => route.isFirst);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(createProvider.errorMessage ?? 'Ошибка создания записи')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GetSlotsProvider>(
      builder: (context, provider, child) {
        final bg = Theme.of(context).scaffoldBackgroundColor;
        return Scaffold(
          backgroundColor: bg,
          appBar: AppBar(
            title: Text('Выбор времени — ${widget.serviceName}'),
          ),
          body: ColoredBox(
            color: bg,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                WeekCalendar(
                  selectedDate: _selectedDate,
                  onDateSelected: (date) {
                    setState(() {
                      _selectedDate = date;
                      _selectedSlot = null;
                    });
                    _scheduleLoadSlotsForDate(date);
                  },
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: _buildTimeSlots(provider),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _selectedSlot == null
                          ? null
                          : _createAppointment,
                      child: const Text('Записаться', style: TextStyle(fontSize: 16)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTimeSlots(GetSlotsProvider provider) {
    if (provider.isLoading && (provider.list == null || provider.list!.isEmpty)) {
      return const Center(child: LoadingIndicator(message: 'Загрузка слотов...'));
    }

    if (provider.errorMessage != null && (provider.list == null || provider.list!.isEmpty)) {
      return Center(
        child: ErrorWidgetCustom(
          message: provider.errorMessage!,
          onRetry: () => _scheduleLoadSlotsForDate(_selectedDate, immediate: true),
        ),
      );
    }

    final slots = provider.list;
    if (slots == null || slots.isEmpty) {
      return const Center(
        child: Text('На этот день нет доступных слотов'),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 1.5,
      ),
      itemCount: slots.length,
      itemBuilder: (context, index) {
        final slot = slots[index];
        final isSelected = _selectedSlot == slot;
        return TimeSlotButton(
          time: _formatSlotLabel(
            slot.startTime ?? '',
            slot.endTime ?? '',
          ),
          isSelected: isSelected,
          onTap: () {
            setState(() {
              _selectedSlot = slot;
            });
          },
        );
      },
    );
  }

  String _normalizeSlotTime(String value) {
    final parts = value.split(':');
    if (parts.length >= 2) {
      return '${parts[0].padLeft(2, '0')}:${parts[1].padLeft(2, '0')}';
    }
    return value;
  }

  String _formatSlotLabel(String start, String end) {
    final normalizedStart = _normalizeSlotTime(start);
    final normalizedEnd = _normalizeSlotTime(end);
    if (normalizedEnd.isEmpty) return normalizedStart;
    return '$normalizedStart-$normalizedEnd';
  }
}

class WeekCalendar extends StatelessWidget {
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateSelected;

  const WeekCalendar({
    super.key,
    required this.selectedDate,
    required this.onDateSelected,
  });

  @override
  Widget build(BuildContext context) {
    final startOfWeek = selectedDate.subtract(Duration(days: selectedDate.weekday - 1));
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return Material(
      color: Theme.of(context).colorScheme.surface,
      elevation: 1,
      shadowColor: Colors.black.withValues(alpha: 0.2),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: () {
                  final newStart = startOfWeek.subtract(const Duration(days: 7));
                  if (!_isPastWeek(newStart)) {
                    final now = DateTime.now();
                    final todayDate = DateTime(now.year, now.month, now.day);
                    final endOfPrevWeek = newStart.add(const Duration(days: 6));
                    final endOfPrevWeekDate = DateTime(endOfPrevWeek.year, endOfPrevWeek.month, endOfPrevWeek.day);
                    final isTodayInPrevWeek = !todayDate.isBefore(newStart) && !todayDate.isAfter(endOfPrevWeekDate);
                    onDateSelected(isTodayInPrevWeek ? todayDate : newStart);
                  }
                },
              ),
              Text(
                _formatDateRange(startOfWeek, startOfWeek.add(const Duration(days: 6))),
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: () {
                  final newStart = startOfWeek.add(const Duration(days: 7));
                  onDateSelected(newStart);
                },
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(7, (index) {
              final date = startOfWeek.add(Duration(days: index));
              final dateOnly = DateTime(date.year, date.month, date.day);
              final isSelected = date.year == selectedDate.year &&
                  date.month == selectedDate.month &&
                  date.day == selectedDate.day;
              final isPast = dateOnly.isBefore(today);
              return _buildDayCell(context, date, isSelected, isPast);
            }),
          ),
        ],
        ),
      ),
    );
  }

  Widget _buildDayCell(
    BuildContext context,
    DateTime date,
    bool isSelected,
    bool isPast,
  ) {
    final weekdayName = _getWeekdayShort(date.weekday);
    final dayNumber = date.day.toString();

    return GestureDetector(
      onTap: isPast ? null : () => onDateSelected(date),
      child: Container(
        width: 40,
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Theme.of(context).colorScheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            Text(
              weekdayName,
              style: TextStyle(
                fontSize: 12,
                color: isPast
                    ? Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.45)
                    : (isSelected
                        ? Theme.of(context).colorScheme.onPrimary
                        : Theme.of(context).colorScheme.onSurface),
              ),
            ),
            Text(
              dayNumber,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isPast
                    ? Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.45)
                    : (isSelected
                        ? Theme.of(context).colorScheme.onPrimary
                        : Theme.of(context).colorScheme.onSurface),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getWeekdayShort(int weekday) {
    const days = ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Вс'];
    return days[weekday - 1];
  }

  String _formatDateRange(DateTime start, DateTime end) {
    return '${start.day} ${_getMonth(start.month)} — ${end.day} ${_getMonth(end.month)} ${end.year}';
  }

  String _getMonth(int month) {
    const months = ['янв', 'фев', 'мар', 'апр', 'май', 'июн', 'июл', 'авг', 'сен', 'окт', 'ноя', 'дек'];
    return months[month - 1];
  }

  bool _isPastWeek(DateTime startOfWeek) {
    final now = DateTime.now();
    final todayDate = DateTime(now.year, now.month, now.day);
    final endOfWeek = startOfWeek.add(const Duration(days: 6));
    final endOfWeekDate = DateTime(endOfWeek.year, endOfWeek.month, endOfWeek.day);
    return endOfWeekDate.isBefore(todayDate);
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}

class TimeSlotButton extends StatelessWidget {
  final String time;
  final bool isSelected;
  final VoidCallback onTap;

  const TimeSlotButton({
    super.key,
    required this.time,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.outline,
          ),
        ),
        child: Center(
          child: Text(
            time,
            style: TextStyle(
              color: isSelected
                  ? Theme.of(context).colorScheme.onPrimary
                  : Theme.of(context).colorScheme.onSurface,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}