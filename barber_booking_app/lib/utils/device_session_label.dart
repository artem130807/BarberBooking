String formatSessionDeviceLabel(String devices) {
  final i = devices.indexOf('|');
  if (i > 0 && i < devices.length - 1) {
    final plat = devices.substring(0, i);
    final suffix = devices.substring(i + 1);
    final short = suffix.length > 12 ? '${suffix.substring(0, 8)}…' : suffix;
    return '${_platRu(plat)} · $short';
  }
  if (devices.length > 28) {
    return '${devices.substring(0, 24)}…';
  }
  return devices.isEmpty ? 'Неизвестное устройство' : devices;
}

String _platRu(String slug) {
  switch (slug.toLowerCase()) {
    case 'android':
      return 'Android';
    case 'ios':
      return 'iOS';
    case 'web':
      return 'Веб';
    case 'linux':
      return 'Linux';
    case 'macos':
      return 'macOS';
    case 'windows':
      return 'Windows';
    default:
      return slug;
  }
}
