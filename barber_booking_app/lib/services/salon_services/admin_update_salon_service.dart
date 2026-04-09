import 'dart:convert';

import 'package:barber_booking_app/config/api_config.dart';
import 'package:barber_booking_app/models/salon_models/request/update_salon_request.dart';
import 'package:http/http.dart' as http;

class AdminUpdateSalonService {
  Map<String, String> _headers(String? token) => {
        'Content-Type': 'application/json',
        if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
      };

  Future<({bool ok, String? error})> patch(
    String salonId,
    UpdateSalonRequest body,
    String? token,
  ) async {
    try {
      final url = Uri.parse('$kApiBaseUrl/api/Salon/UpdateSalon$salonId');
      final response = await http.patch(
        url,
        headers: _headers(token),
        body: json.encode(body.toJson()),
      );
      if (response.statusCode == 200) {
        return (ok: true, error: null);
      }
      String? err;
      try {
        final decoded = json.decode(response.body);
        if (decoded is Map) {
          final e = decoded['error'] ?? decoded['title'] ?? decoded['message'];
          if (e != null) err = e.toString();
        }
      } catch (_) {}
      return (ok: false, error: err ?? 'Ошибка ${response.statusCode}');
    } catch (e) {
      return (ok: false, error: e.toString());
    }
  }
}
