import 'dart:io';

import 'package:barber_booking_app/models/appointment_models/response/salon_appointment_admin_response.dart';
import 'package:barber_booking_app/models/review_models/response/review_admin_list_item.dart';
import 'package:barber_booking_app/models/salon_models/response/salon_statistic_period_response.dart';
import 'package:barber_booking_app/models/salon_models/response/salon_stats_dto.dart';
import 'package:barber_booking_app/utils/appointment_status_normalize.dart';
import 'package:barber_booking_app/utils/appointment_status_ru.dart';
import 'package:barber_booking_app/utils/appointment_time_display.dart';
import 'package:excel/excel.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class AdminExcelExportService {
  AdminExcelExportService._();
  static final AdminExcelExportService instance = AdminExcelExportService._();

  static final _df = DateFormat('dd.MM.yyyy HH:mm');
  static final _dfDate = DateFormat('dd.MM.yyyy');
  static final _money = NumberFormat('#,##0.00', 'ru_RU');

  Future<void> shareAppointments(
    List<SalonAppointmentAdminResponse> rows,
    String fileBaseName, {
    bool includeRevenueSummary = false,
  }) async {
    final excel = Excel.createExcel();
    final def = excel.getDefaultSheet() ?? 'Sheet1';
    excel.rename(def, 'Records');
    excel.appendRow('Records', [
      TextCellValue('Дата записи'),
      TextCellValue('Время'),
      TextCellValue('Клиент'),
      TextCellValue('Мастер'),
      TextCellValue('Услуга'),
      TextCellValue('Цена'),
      TextCellValue('Статус'),
      TextCellValue('Салон'),
      TextCellValue('Создано'),
    ]);
    for (final a in rows) {
      final ad = a.AppointmentDate;
      final dateStr = ad != null ? _dfDate.format(ad.toLocal()) : '';
      final timeStr = formatAppointmentSlotTime(a.StartTime);
      final client = a.dtoUsersNavigation?.Name ?? '';
      final master = a.dtoMasterProfileNavigation?.MasterName ?? '';
      final service = a.dtoServicesNavigation?.Name ?? '';
      final price = a.dtoServicesNavigation?.Price?.Value;
      final status = appointmentStatusLabelRu(a.Status);
      final salon = a.SalonName ?? '';
      final created = a.CreatedAt != null
          ? _df.format(a.CreatedAt!.toLocal())
          : '';
      excel.appendRow('Records', [
        TextCellValue(dateStr),
        TextCellValue(timeStr),
        TextCellValue(client),
        TextCellValue(master),
        TextCellValue(service),
        price != null ? DoubleCellValue(price) : TextCellValue(''),
        TextCellValue(status),
        TextCellValue(salon),
        TextCellValue(created),
      ]);
    }
    if (includeRevenueSummary) {
      excel['Summary'];
      var sum = 0.0;
      var n = 0;
      for (final a in rows) {
        if (!_isCompletedStatus(a.Status)) continue;
        n++;
        final v = a.dtoServicesNavigation?.Price?.Value;
        if (v != null) sum += v;
      }
      excel.appendRow('Summary', [
        TextCellValue('Завершено записей'),
        IntCellValue(n),
      ]);
      excel.appendRow('Summary', [
        TextCellValue('Сумма по услугам'),
        TextCellValue(_money.format(sum)),
      ]);
      excel.setDefaultSheet('Records');
    }
    await _shareExcel(excel, fileBaseName);
  }

  Future<void> shareReviews(
    List<ReviewAdminListItem> rows,
    String fileBaseName,
  ) async {
    final excel = Excel.createExcel();
    final def = excel.getDefaultSheet() ?? 'Sheet1';
    excel.rename(def, 'Reviews');
    excel.appendRow('Reviews', [
      TextCellValue('Дата'),
      TextCellValue('Клиент'),
      TextCellValue('Салон'),
      TextCellValue('Мастер'),
      TextCellValue('Услуга'),
      TextCellValue('Оценка салона'),
      TextCellValue('Оценка мастера'),
      TextCellValue('Комментарий'),
    ]);
    for (final r in rows) {
      final created = r.CreatedAt != null
          ? _df.format(r.CreatedAt!.toLocal())
          : '';
      final salon = r.dtoSalonNavigation?.SalonName ?? '';
      final master = r.masterProfileNavigation?.MasterName ?? '';
      final service = r.dtoAppointmentNavigation?.ServiceName ?? '';
      excel.appendRow('Reviews', [
        TextCellValue(created),
        TextCellValue(r.ClientName ?? ''),
        TextCellValue(salon),
        TextCellValue(master),
        TextCellValue(service),
        IntCellValue(r.SalonRating ?? 0),
        IntCellValue(r.MasterRating ?? 0),
        TextCellValue(r.Comment ?? ''),
      ]);
    }
    await _shareExcel(excel, fileBaseName);
  }

  Future<void> shareSalonPeriodSummary(
    SalonStatisticPeriodResponse r,
    String fileBaseName, {
    required String periodKindLabel,
    required String periodRangeLabel,
  }) async {
    final excel = Excel.createExcel();
    final def = excel.getDefaultSheet() ?? 'Sheet1';
    excel.rename(def, 'Period');
    excel.appendRow('Period', [
      TextCellValue('Параметр'),
      TextCellValue('Значение'),
    ]);
    excel.appendRow('Period', [
      TextCellValue('Салон'),
      TextCellValue(r.salonId),
    ]);
    excel.appendRow('Period', [
      TextCellValue('Тип периода'),
      TextCellValue(periodKindLabel),
    ]);
    excel.appendRow('Period', [
      TextCellValue('Период'),
      TextCellValue(periodRangeLabel),
    ]);
    excel.appendRow('Period', [
      TextCellValue('Завершено записей'),
      IntCellValue(r.completedAppointmentsCount),
    ]);
    excel.appendRow('Period', [
      TextCellValue('Отменено записей'),
      IntCellValue(r.cancelledAppointmentsCount),
    ]);
    excel.appendRow('Period', [
      TextCellValue('Рейтинг (сумма оценок)'),
      DoubleCellValue(r.rating),
    ]);
    excel.appendRow('Period', [
      TextCellValue('Количество оценок'),
      IntCellValue(r.ratingCount),
    ]);
    excel.appendRow('Period', [
      TextCellValue('Выручка'),
      TextCellValue(_money.format(r.sumPrice)),
    ]);
    await _shareExcel(excel, fileBaseName);
  }

  Future<void> shareSalonDailySnapshots(
    List<SalonStatsDto> rows,
    String fileBaseName, {
    String? filterDescription,
  }) async {
    final excel = Excel.createExcel();
    final def = excel.getDefaultSheet() ?? 'Sheet1';
    excel.rename(def, 'Daily');
    if (filterDescription != null && filterDescription.isNotEmpty) {
      excel.appendRow('Daily', [
        TextCellValue('Фильтр'),
        TextCellValue(filterDescription),
      ]);
    }
    excel.appendRow('Daily', [
      TextCellValue('Дата снимка'),
      TextCellValue('Завершено'),
      TextCellValue('Отменено'),
      TextCellValue('Рейтинг (сумма)'),
      TextCellValue('Оценок'),
      TextCellValue('Выручка'),
      TextCellValue('Салон'),
    ]);
    for (final e in rows) {
      excel.appendRow('Daily', [
        TextCellValue(_df.format(e.createdAt)),
        IntCellValue(e.completedAppointmentsCount),
        IntCellValue(e.cancelledAppointmentsCount),
        DoubleCellValue(e.rating),
        IntCellValue(e.ratingCount),
        DoubleCellValue(e.sumPrice),
        TextCellValue(e.salonId),
      ]);
    }
    await _shareExcel(excel, fileBaseName);
  }

  Future<void> _shareExcel(Excel excel, String fileBaseName) async {
    final bytes = excel.encode();
    if (bytes == null) {
      throw StateError('encode');
    }
    final dir = await getTemporaryDirectory();
    final name = _sanitizeBaseName(fileBaseName);
    final path = '${dir.path}/$name.xlsx';
    final f = File(path);
    await f.writeAsBytes(bytes, flush: true);
    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(path)],
        subject: name,
      ),
    );
  }

  String _sanitizeBaseName(String raw) {
    final s = raw.replaceAll(
      RegExp(r'[^\p{L}\p{N}\._\-]', unicode: true),
      '_',
    );
    if (s.isEmpty) return 'export_${DateTime.now().millisecondsSinceEpoch}';
    if (s.length <= 80) return s;
    return s.substring(0, 80);
  }

  static bool _isCompletedStatus(String? status) =>
      normalizeAppointmentStatus(status) == 'Completed';
}
