import 'dart:convert';

import 'package:barber_booking_app/config/api_config.dart';
import 'package:barber_booking_app/models/salon_models/request/create_salon_request.dart';
import 'package:barber_booking_app/models/salon_models/response/salon_create_info_response.dart';
import 'package:http/http.dart' as http;

class AdminCreateSalonService {
  Map<String, String> _headers(String? token) => {
        'Content-Type': 'application/json',
        if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
      };

  Future<({bool ok, SalonCreateInfoResponse? data, String? error})> create(
    CreateSalonRequest body,
    String? token,
  ) async {
    try {
      final url = Uri.parse('$kApiBaseUrl/api/Salon/CreateSalon');
      final response = await http.post(
        url,
        headers: _headers(token),
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
