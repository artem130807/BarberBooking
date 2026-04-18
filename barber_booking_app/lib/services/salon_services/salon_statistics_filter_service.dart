import 'dart:convert';

import 'package:barber_booking_app/config/api_config.dart';
import 'package:barber_booking_app/models/salon_models/response/salon_stats_dto.dart';
import 'package:barber_booking_app/services/auth_services/auth_http_headers.dart';
import 'package:http/http.dart' as http;

class SalonStatisticsFilterService {
  Future<({List<SalonStatsDto>? data, String? error})> fetch({
    required String salonId,
    int? dayOfMonth,
  }) async {
    final params = <String, String>{'salonId': salonId};
    if (dayOfMonth != null) {
      params['day'] = '$dayOfMonth';
    }
    final uri =
        Uri.parse('$kApiBaseUrl/api/SalonStatistics/GetSalonStatistics').replace(
      queryParameters: params,
    );
    try {
      final headers = await AuthHttpHeaders.bearerJson();
      if (headers == null) {
        return (data: null, error: 'Нет авторизации');
      }
      final response = await http.get(
        uri,
        headers: headers,
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
