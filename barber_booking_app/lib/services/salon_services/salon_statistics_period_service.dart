import 'dart:convert';

import 'package:barber_booking_app/config/api_config.dart';
import 'package:barber_booking_app/models/salon_models/response/salon_statistic_period_response.dart';
import 'package:http/http.dart' as http;

class SalonStatisticsPeriodService {
  String _dateOnly(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  Future<({SalonStatisticPeriodResponse? data, String? error})> fetchWeek({
    required String salonId,
    required DateTime anchorInWeek,
    required String? token,
  }) async {
    // Неделя считается на API по statisticsParams.Date (календарная неделя UTC).
    final uri = Uri.parse('$kApiBaseUrl/api/SalonStatistics/GetSalonStatisticWeek').replace(
      queryParameters: {
        'salonId': salonId,
        'statisticsParams.Date': _dateOnly(anchorInWeek),
      },
    );
    return _get(uri, token);
  }

  Future<({SalonStatisticPeriodResponse? data, String? error})> fetchMonth({
    required String salonId,
    required int year,
    required int month,
    required String? token,
  }) async {
    final uri = Uri.parse('$kApiBaseUrl/api/SalonStatistics/GetSalonStatisticMounth').replace(
      queryParameters: {
        'salonId': salonId,
        'mounth': '$month',
        'date': _dateOnly(DateTime(year, month, 1)),
      },
    );
    return _get(uri, token);
  }

  Future<({SalonStatisticPeriodResponse? data, String? error})> fetchYear({
    required String salonId,
    required int year,
    required String? token,
  }) async {
    final uri = Uri.parse('$kApiBaseUrl/api/SalonStatistics/GetSalonStatisticYear').replace(
      queryParameters: {
        'salonId': salonId,
        'date': _dateOnly(DateTime(year, 1, 1)),
      },
    );
    return _get(uri, token);
  }

  Future<({SalonStatisticPeriodResponse? data, String? error})> _get(
    Uri uri,
    String? token,
  ) async {
    try {
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        final map = json.decode(response.body) as Map<String, dynamic>;
        return (data: SalonStatisticPeriodResponse.fromJson(map), error: null);
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
