import 'package:barber_booking_app/models/time_slot_models/request/get_slots_request.dart';
import 'package:barber_booking_app/models/time_slot_models/response/get_available_slots.dart';

abstract final class AvailableSlotsFilter {
  static const int _leadMinutes = 15;

  static List<GetAvailableSlots> apply(
    List<GetAvailableSlots> slots,
    GetSlotsRequest request,
  ) {
    final ds = request.DateTime?.trim();
    if (ds == null || ds.isEmpty) return slots;

    DateTime? day;
    final parts = ds.split('-');
    if (parts.length == 3) {
      final y = int.tryParse(parts[0]);
      final m = int.tryParse(parts[1]);
      final d = int.tryParse(parts[2]);
      if (y != null && m != null && d != null) {
        day = DateTime(y, m, d);
      }
    }
    day ??= DateTime.tryParse(ds);
    if (day == null) return slots;

    final cal = DateTime(day.year, day.month, day.day);
    final now = DateTime.now();
    final sameDay = cal.year == now.year &&
        cal.month == now.month &&
        cal.day == now.day;
    if (!sameDay) return slots;

    var earliest = DateTime(now.year, now.month, now.day, now.hour, now.minute);
    if (now.second > 0 ||
        now.millisecond > 0 ||
        now.microsecond > 0) {
      earliest = earliest.add(const Duration(minutes: 1));
    }
    earliest = earliest.add(const Duration(minutes: _leadMinutes));

    return slots.where((slot) {
      final start = _parseStartOnDay(slot.startTime, cal);
      if (start == null) return true;
      return !start.isBefore(earliest);
    }).toList();
  }

  static DateTime? _parseStartOnDay(String? timeStr, DateTime day) {
    if (timeStr == null || timeStr.isEmpty) return null;
    final p = timeStr.trim().split(':');
    if (p.length < 2) return null;
    final h = int.tryParse(p[0].trim());
    final m = int.tryParse(p[1].trim());
    if (h == null || m == null) return null;
    var s = 0;
    if (p.length > 2) {
      final secPart = p[2].split('.').first.trim();
      s = int.tryParse(secPart) ?? 0;
    }
    return DateTime(day.year, day.month, day.day, h, m, s);
  }
}
