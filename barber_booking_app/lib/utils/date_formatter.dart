import 'package:intl/intl.dart';

class DateFormatter {
   static String formatDateTime(String isoString) {
    try {
      final dateTime = DateTime.parse(isoString);
      return DateFormat('HH:mm dd.MM.yyyy').format(dateTime);
    } catch (e) {
      return isoString;
    }
  }

  static String formatDateOnly(String isoString) {
    try {
      final dateTime = DateTime.parse(isoString);
      return DateFormat('dd.MM.yyyy').format(dateTime);
    } catch (e) {
      return isoString;
    }
  }

  static String formatTimeOnly(String isoString) {
    try {
      final dateTime = DateTime.parse(isoString);
      return DateFormat('HH:mm').format(dateTime);
    } catch (e) {
      return isoString;
    }
  }
}