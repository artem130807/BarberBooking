/// Приводит статус записи к имени enum API (`Confirmed` / `Completed` / `Cancelled`).
/// Учитывает числовой JSON enum (0/1/2), если когда-либо придёт с бэкенда.
String? normalizeAppointmentStatus(String? raw) {
  if (raw == null) return null;
  final s = raw.trim();
  if (s.isEmpty) return null;
  switch (s) {
    case '0':
      return 'Confirmed';
    case '1':
      return 'Completed';
    case '2':
      return 'Cancelled';
    default:
      return s;
  }
}

bool appointmentStatusIsConfirmed(String? normalized) =>
    normalized == 'Confirmed';

bool appointmentStatusIsTerminal(String? normalized) =>
    normalized == 'Completed' || normalized == 'Cancelled';
