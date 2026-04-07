String templateDayLabelRu(int apiDayOfWeek) {
  if (apiDayOfWeek < 0 || apiDayOfWeek > 6) return 'День $apiDayOfWeek';
  const labels = ['Вс', 'Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб'];
  return labels[apiDayOfWeek];
}

String templateDayLongLabelRu(int apiDayOfWeek) {
  if (apiDayOfWeek < 0 || apiDayOfWeek > 6) return 'День $apiDayOfWeek';
  const labels = [
    'Воскресенье',
    'Понедельник',
    'Вторник',
    'Среда',
    'Четверг',
    'Пятница',
    'Суббота',
  ];
  return labels[apiDayOfWeek];
}

int templateDaySortKey(int apiDayOfWeek) {
  if (apiDayOfWeek == 0) return 7;
  return apiDayOfWeek;
}

List<int> templateDaysOrderedForPicker() {
  return [1, 2, 3, 4, 5, 6, 0];
}
