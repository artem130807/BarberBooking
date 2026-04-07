import 'dart:convert';

import 'package:barber_booking_app/config/api_config.dart';
import 'package:barber_booking_app/models/master_interface_models/request/create_template_day_request.dart';
import 'package:barber_booking_app/models/master_interface_models/request/update_template_day_request.dart';
import 'package:barber_booking_app/models/master_interface_models/request/create_weekly_template_request.dart';
import 'package:barber_booking_app/models/master_interface_models/response/template_day_info.dart';
import 'package:barber_booking_app/models/master_interface_models/response/weekly_template_info.dart';
import 'package:barber_booking_app/models/master_interface_models/response/weekly_template_short_info.dart';
import 'package:http/http.dart' as http;

class WeeklyTemplateService {
  Map<String, String> _headers(String token) => {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

  String _dateIso(DateTime d) {
    final y = d.year.toString().padLeft(4, '0');
    final m = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    return '$y-$m-$day';
  }

  String? _errorFromResponse(http.Response r) {
    if (r.statusCode >= 200 && r.statusCode < 300) return null;
    final raw = r.body;
    if (raw.isEmpty) return 'Ошибка ${r.statusCode}';
    try {
      final j = json.decode(raw);
      if (j is Map && j['error'] != null) return j['error'].toString();
      if (j is String) return j;
    } catch (_) {}
    return raw.length > 220 ? 'Ошибка ${r.statusCode}' : raw;
  }

  Future<List<WeeklyTemplateShortInfo>?> fetchTemplates(String? token) async {
    if (token == null || token.isEmpty) return null;
    try {
      final url = Uri.parse('$kApiBaseUrl/api/WeeklyTemplate/get-weekly-templates');
      final response = await http.get(url, headers: _headers(token));
      if (response.statusCode != 200) return null;
      final decoded = json.decode(response.body);
      if (decoded is! List) return null;
      return decoded
          .map((e) => WeeklyTemplateShortInfo.fromJson(
                Map<String, dynamic>.from(e as Map),
              ))
          .toList();
    } catch (_) {
      return null;
    }
  }

  Future<WeeklyTemplateInfo?> fetchTemplateById(String? token, String id) async {
    if (token == null || token.isEmpty || id.isEmpty) return null;
    try {
      final url = Uri.parse('$kApiBaseUrl/api/WeeklyTemplate/get-weekly-template/$id');
      final response = await http.get(url, headers: _headers(token));
      if (response.statusCode != 200) return null;
      final map = json.decode(response.body) as Map<String, dynamic>;
      return WeeklyTemplateInfo.fromJson(map);
    } catch (_) {
      return null;
    }
  }

  Future<(String? id, String? error)> createTemplate({
    required String? token,
    required CreateWeeklyTemplateRequest body,
  }) async {
    if (token == null || token.isEmpty) return (null, 'Нужна авторизация');
    try {
      final url = Uri.parse('$kApiBaseUrl/api/WeeklyTemplate/create-weekly-templates');
      final response = await http.post(
        url,
        headers: _headers(token),
        body: json.encode(body.toJson()),
      );
      if (response.statusCode == 200) {
        final raw = response.body;
        if (raw.isEmpty) return (null, 'Пустой ответ');
        try {
          final decoded = json.decode(raw);
          final id = decoded is String ? decoded : decoded.toString();
          return (id, null);
        } catch (_) {
          return (null, raw);
        }
      }
      return (null, _errorFromResponse(response) ?? 'Не удалось создать шаблон');
    } catch (_) {
      return (null, 'Ошибка сети');
    }
  }

  Future<String?> deleteTemplate({
    required String? token,
    required String id,
  }) async {
    if (token == null || token.isEmpty) return 'Нужна авторизация';
    try {
      final url = Uri.parse('$kApiBaseUrl/api/WeeklyTemplate/delete-weekly-templates/$id');
      final response = await http.delete(url, headers: _headers(token));
      if (response.statusCode == 200) return null;
      return _errorFromResponse(response) ?? 'Не удалось удалить';
    } catch (_) {
      return 'Ошибка сети';
    }
  }

  Future<List<TemplateDayInfo>?> fetchTemplateDays(String? token, String weeklyTemplateId) async {
    if (token == null || token.isEmpty || weeklyTemplateId.isEmpty) return null;
    try {
      final url = Uri.parse(
        '$kApiBaseUrl/api/TemplateDay/get-template-days/$weeklyTemplateId',
      );
      final response = await http.get(url, headers: _headers(token));
      if (response.statusCode != 200) return null;
      final decoded = json.decode(response.body);
      if (decoded is! List) return null;
      return decoded
          .map((e) => TemplateDayInfo.fromJson(
                Map<String, dynamic>.from(e as Map),
              ))
          .toList();
    } catch (_) {
      return null;
    }
  }

  Future<String?> createTemplateDay({
    required String? token,
    required CreateTemplateDayRequest body,
  }) async {
    if (token == null || token.isEmpty) return 'Нужна авторизация';
    try {
      final url = Uri.parse('$kApiBaseUrl/api/TemplateDay/create-template-day');
      final response = await http.post(
        url,
        headers: _headers(token),
        body: json.encode(body.toJson()),
      );
      if (response.statusCode == 200) return null;
      return _errorFromResponse(response) ?? 'Не удалось добавить день';
    } catch (_) {
      return 'Ошибка сети';
    }
  }

  Future<String?> updateTemplateDay({
    required String? token,
    required String templateDayId,
    required UpdateTemplateDayRequest body,
  }) async {
    if (token == null || token.isEmpty) return 'Нужна авторизация';
    try {
      final url = Uri.parse('$kApiBaseUrl/api/TemplateDay/update-template-day/$templateDayId');
      final response = await http.patch(
        url,
        headers: _headers(token),
        body: json.encode(body.toJson()),
      );
      if (response.statusCode == 200) return null;
      return _errorFromResponse(response) ?? 'Не удалось сохранить';
    } catch (_) {
      return 'Ошибка сети';
    }
  }

  Future<String?> deleteTemplateDay({
    required String? token,
    required String id,
  }) async {
    if (token == null || token.isEmpty) return 'Нужна авторизация';
    try {
      final url = Uri.parse('$kApiBaseUrl/api/TemplateDay/delete-template-day/$id');
      final response = await http.delete(url, headers: _headers(token));
      if (response.statusCode == 200) return null;
      return _errorFromResponse(response) ?? 'Не удалось удалить';
    } catch (_) {
      return 'Ошибка сети';
    }
  }

  Future<(String? message, String? error)> createSlotsFromWeeklyTemplate({
    required String? token,
    required String weeklyTemplateId,
    required DateTime dateFrom,
    required DateTime dateTo,
  }) async {
    if (token == null || token.isEmpty) return (null, 'Нужна авторизация');
    final from = DateTime(dateFrom.year, dateFrom.month, dateFrom.day);
    final to = DateTime(dateTo.year, dateTo.month, dateTo.day);
    if (from.isAfter(to)) return (null, 'Дата «с» позже даты «по»');
    try {
      final uri = Uri.parse(
        '$kApiBaseUrl/api/MasterTimeSlot/timeSlot-createRangeByWeeklyTemplateHandler/$weeklyTemplateId',
      ).replace(queryParameters: {
        'dateFrom': _dateIso(from),
        'dateTo': _dateIso(to),
      });
      final response = await http.post(uri, headers: _headers(token));
      if (response.statusCode == 200) {
        final raw = response.body;
        if (raw.isEmpty) return ('Готово', null);
        try {
          final decoded = json.decode(raw);
          final msg = decoded is String ? decoded : decoded.toString();
          return (msg, null);
        } catch (_) {
          return (raw, null);
        }
      }
      return (null, _errorFromResponse(response) ?? 'Не удалось создать слоты');
    } catch (_) {
      return (null, 'Ошибка сети');
    }
  }
}
