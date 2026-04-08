DateTime mondayOfWeekContaining(DateTime d) {
  final day = DateTime(d.year, d.month, d.day);
  return day.subtract(Duration(days: day.weekday - DateTime.monday));
}

DateTime dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

DateTime? parseAppointmentDate(String? raw) {
  if (raw == null || raw.isEmpty) return null;
  return DateTime.tryParse(raw)?.toLocal();
}

DateTime firstGridDayForMonthPage(DateTime month) {
  final first = DateTime(month.year, month.month, 1);
  return first.subtract(Duration(days: first.weekday - DateTime.monday));
}

const kWeekdayShortRu = ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Вс'];

String appointmentCountRu(int n) {
  if (n <= 0) return 'нет записей';
  final mod10 = n % 10;
  final mod100 = n % 100;
  if (mod100 >= 11 && mod100 <= 14) return '$n записей';
  if (mod10 == 1) return '$n запись';
  if (mod10 >= 2 && mod10 <= 4) return '$n записи';
  return '$n записей';
}

const kMonthNamesRu = [
  'Январь',
  'Февраль',
  'Март',
  'Апрель',
  'Май',
  'Июнь',
  'Июль',
  'Август',
  'Сентябрь',
  'Октябрь',
  'Ноябрь',
  'Декабрь',
];
