import 'package:barber_booking_app/utils/appointment_status_normalize.dart';

String appointmentStatusLabelRu(String? status) {
  if (status == null || status.isEmpty) return '—';
  final normalized = normalizeAppointmentStatus(status);
  if (normalized == null || normalized.isEmpty) return '—';
  switch (normalized.toLowerCase()) {
    case 'confirmed':
      return 'Подтверждена';
    case 'completed':
      return 'Завершена';
    case 'cancelled':
      return 'Отменена';
    case 'pending':
      return 'Ожидает подтверждения';
    default:
      return normalized;
  }
}
