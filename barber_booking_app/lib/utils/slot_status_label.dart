String slotStatusLabelRu(String? status) {
  switch (status) {
    case 'Available':
      return 'Свободен';
    case 'Booked':
      return 'Занят';
    case 'Cancelled':
      return 'Отменён';
    default:
      return status ?? '—';
  }
}
