/// Подписи для статусов записи. С бэка приходят имена enum, как в `AppointmentStatusEnum`.
String appointmentStatusLabelRu(String? status) {
  if (status == null || status.isEmpty) return '—';
  final s = status.trim();
  final lower = s.toLowerCase();
  switch (lower) {
    case 'confirmed':
      return 'Подтверждена';
    case 'completed':
      return 'Завершена';
    case 'cancelled':
      return 'Отменена';
    case 'pending':
      return 'Ожидает подтверждения';
    default:
      // На случай числовой сериализации enum
      switch (s) {
        case '0':
          return 'Ожидает подтверждения';
        case '1':
          return 'Подтверждена';
        case '2':
          return 'Завершена';
        case '3':
          return 'Отменена';
        default:
          return s;
      }
  }
}
