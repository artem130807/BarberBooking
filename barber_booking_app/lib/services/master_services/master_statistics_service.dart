import 'dart:convert';

import 'package:barber_booking_app/config/api_config.dart';
import 'package:barber_booking_app/models/master_models/response/master_statistic_response.dart';
import 'package:barber_booking_app/services/auth_services/auth_http_headers.dart';
import 'package:http/http.dart' as http;

class MasterStatisticsService {
  Future<MasterStatisticResponse?> fetchWeek({
    required int month,
    required int week,
    required DateTime anchorDate,
  }) async {
    return _get(
      Uri.parse('$kApiBaseUrl/api/MasterStatistics/GetMyStatisticWeek').replace(
        queryParameters: {
          'Mounth': '$month',
          'Week': '$week',
          'Date': _dateOnly(anchorDate),
        },
      ),
    );
  }

  Future<MasterStatisticResponse?> fetchMonth({
    required int month,
    required DateTime anchorDate,
  }) async {
    return _get(
      Uri.parse('$kApiBaseUrl/api/MasterStatistics/GetMyStatisticMounth').replace(
        queryParameters: {
          'mounth': '$month',
          'date': _dateOnly(anchorDate),
        },
      ),
    );
  }

  Future<MasterStatisticResponse?> fetchYear({
    required DateTime anchorDate,
  }) async {
    return _get(
      Uri.parse('$kApiBaseUrl/api/MasterStatistics/GetMyStatisticYear').replace(
        queryParameters: {
          'date': _dateOnly(anchorDate),
        },
      ),
    );
  }

  String _dateOnly(DateTime d) {
    final l = d.toLocal();
    final y = l.year.toString().padLeft(4, '0');
    final m = l.month.toString().padLeft(2, '0');
    final day = l.day.toString().padLeft(2, '0');
    return '$y-$m-$day';
  }

  Future<MasterStatisticResponse?> _get(Uri url) async {
    final headers = await AuthHttpHeaders.bearerJson();
    if (headers == null) return null;
    try {
      final response = await http.get(
        url,
        headers: headers,
      );
      if (response.statusCode != 200) return null;
      final decoded = json.decode(response.body);
      if (decoded is! Map<String, dynamic>) return null;
      return MasterStatisticResponse.fromJson(decoded);
    } catch (_) {
      return null;
    }
  }
}
