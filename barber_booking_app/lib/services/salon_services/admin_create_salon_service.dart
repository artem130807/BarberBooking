import 'dart:convert';

import 'package:barber_booking_app/config/api_config.dart';
import 'package:barber_booking_app/models/salon_models/request/create_salon_request.dart';
import 'package:barber_booking_app/models/salon_models/response/salon_create_info_response.dart';
import 'package:barber_booking_app/services/auth_services/auth_http_headers.dart';
import 'package:http/http.dart' as http;

class AdminCreateSalonService {
  Future<({bool ok, SalonCreateInfoResponse? data, String? error})> create(
    CreateSalonRequest body,
  ) async {
    try {
      final headers = await AuthHttpHeaders.bearerJson();
      if (headers == null) {
        return (ok: false, data: null, error: 'Нет авторизации');
      }

      final url = Uri.parse('$kApiBaseUrl/api/Salon/CreateSalon');
      final response = await http.post(
        url,
        headers: headers,
        body: json.encode(body.toJson()),
      );
      if (response.statusCode == 200) {
        final map = json.decode(response.body);
        if (map is Map<String, dynamic>) {
          return (
            ok: true,
            data: SalonCreateInfoResponse.fromJson(map),
            error: null,
          );
        }
        return (ok: true, data: null, error: null);
      }
      String? err;
      try {
        final decoded = json.decode(response.body);
        if (decoded is Map) {
          final e = decoded['error'] ?? decoded['title'] ?? decoded['message'];
          if (e != null) err = e.toString();
        }
      } catch (_) {}
      return (
        ok: false,
        data: null,
        error: err ?? 'Ошибка ${response.statusCode}',
      );
    } catch (e) {
      return (ok: false, data: null, error: e.toString());
    }
  }
}
