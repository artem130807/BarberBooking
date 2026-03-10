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
  DateTime _selectedDate = DateTime.now();
  GetAvailableSlots? _selectedSlot;

  @override
  void initState() {
    super.initState();
    _loadSlotsForDate(_selectedDate);
  }

  void _loadSlotsForDate(DateTime date) {
    final provider = Provider.of<GetSlotsProvider>(context, listen: false);
    final dateStr = DateFormat('yyyy-MM-dd').format(date);
    final duration = Duration(minutes: widget.serviceDuration ?? 0);
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    final durationStr = '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';

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
      // Возвращаемся на главный экран (или на экран записей)
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
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (provider.errorMessage != null && mounted) {
            provider.showApiError(context, provider.errorMessage);
          }
        });

        return Scaffold(
          appBar: AppBar(
            title: Text('Выбор времени — ${widget.serviceName}'),
          ),
          body: Column(
            children: [
              WeekCalendar(
                selectedDate: _selectedDate,
                onDateSelected: (date) {
                  setState(() {
                    _selectedDate = date;
                    _selectedSlot = null;
                  });
                  _loadSlotsForDate(date);
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
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Записаться', style: TextStyle(fontSize: 16)),
                  ),
                ),
              ),
            ],
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
          onRetry: () => _loadSlotsForDate(_selectedDate),
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
          time: slot.startTime ?? '',
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
    final today = DateTime.now();

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
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
                    onDateSelected(newStart.add(const Duration(days: 1)));
                  }
                },
              ),
              Text(
                _formatDateRange(startOfWeek, startOfWeek.add(const Duration(days: 6))),
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
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
              final isSelected = date.year == selectedDate.year &&
                  date.month == selectedDate.month &&
                  date.day == selectedDate.day;
              final isPast = date.isBefore(today) && !_isSameDay(date, today);
              return _buildDayCell(date, isSelected, isPast);
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildDayCell(DateTime date, bool isSelected, bool isPast) {
    final weekdayName = _getWeekdayShort(date.weekday);
    final dayNumber = date.day.toString();

    return GestureDetector(
      onTap: isPast ? null : () => onDateSelected(date),
      child: Container(
        width: 40,
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            Text(
              weekdayName,
              style: TextStyle(
                fontSize: 12,
                color: isPast
                    ? Colors.grey.shade400
                    : (isSelected ? Colors.white : Colors.black87),
              ),
            ),
            Text(
              dayNumber,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isPast
                    ? Colors.grey.shade400
                    : (isSelected ? Colors.white : Colors.black87),
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
    final today = DateTime.now();
    final endOfWeek = startOfWeek.add(const Duration(days: 6));
    return endOfWeek.isBefore(today);
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
          color: isSelected ? Colors.blue : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.grey.shade300,
          ),
        ),
        child: Center(
          child: Text(
            time,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.black87,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}