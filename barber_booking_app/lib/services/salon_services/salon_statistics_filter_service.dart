import 'dart:convert';

import 'package:barber_booking_app/config/api_config.dart';
import 'package:barber_booking_app/models/salon_models/response/salon_stats_dto.dart';
import 'package:http/http.dart' as http;

/// GET GetSalonStatistics — фильтр по салону и (опционально) дню месяца (1–31), плюс город из профиля на API.
class SalonStatisticsFilterService {
  Future<({List<SalonStatsDto>? data, String? error})> fetch({
    required String salonId,
    int? dayOfMonth,
    required String? token,
  }) async {
    final params = <String, String>{'salonId': salonId};
    if (dayOfMonth != null) {
      params['day'] = '$dayOfMonth';
    }
    final uri = Uri.parse('$kApiBaseUrl/api/SalonStatistics/GetSalonStatistics').replace(
      queryParameters: params,
    );
    try {
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        if (decoded is! List) {
          return (data: null, error: 'Неверный формат ответа');
        }
        final list = decoded
            .map((e) => SalonStatsDto.fromJson(e as Map<String, dynamic>))
            .toList()
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
        return (data: list, error: null);
      }
      final err = _parseError(response.body);
      return (data: null, error: err ?? 'Ошибка ${response.statusCode}');
    } catch (e) {
      return (data: null, error: e.toString());
    }
  }

  String? _parseError(String body) {
    try {
      final decoded = json.decode(body);
      if (decoded is Map) {
        final e = decoded['error'] ?? decoded['title'] ?? decoded['message'];
        if (e != null) return e.toString();
      }
      if (decoded is String) return decoded;
    } catch (_) {}
    if (body.isNotEmpty && body.length < 400) return body;
    return null;
  }
}
