import 'dart:convert';

import 'package:barber_booking_app/config/api_config.dart';
import 'package:barber_booking_app/models/salon_models/response/salon_photo_dto.dart';
import 'package:barber_booking_app/services/auth_services/auth_http_headers.dart';
import 'package:http/http.dart' as http;

class SalonPhotosService {
  Future<({List<SalonPhotoDto> items, int count})?> getPhotos(String salonId) async {
    try {
      final url = Uri.parse('$kApiBaseUrl/api/SalonPhotos/get-photos/$salonId').replace(
        queryParameters: {'Page': '1', 'PageSize': '10'},
      );
      final response = await http.get(
        url,
        headers: const {'Content-Type': 'application/json'},
      );
      if (response.statusCode != 200) return null;
      final decoded = json.decode(response.body);
      if (decoded is! Map<String, dynamic>) return null;
      final raw = decoded['data'] ?? decoded['Data'];
      final countRaw = decoded['count'] ?? decoded['Count'];
      final int count = countRaw is num ? countRaw.toInt() : 0;
      if (raw is! List<dynamic>) {
        return (items: <SalonPhotoDto>[], count: count);
      }
      final items = raw
          .whereType<Map<String, dynamic>>()
          .map(SalonPhotoDto.fromJson)
          .toList();
      return (items: items, count: count);
    } catch (_) {
      return null;
    }
  }

  Future<({bool ok, String? error})> createPhoto({
    required String salonId,
    required String photoUrl,
  }) async {
    try {
      final headers = await AuthHttpHeaders.bearerJson();
      if (headers == null) {
        return (ok: false, error: 'Нет авторизации');
      }
      final url = Uri.parse('$kApiBaseUrl/api/SalonPhotos/create-photo');
      final response = await http.post(
        url,
        headers: headers,
        body: json.encode({'salonId': salonId, 'photoUrl': photoUrl}),
      );
      if (response.statusCode == 200) return (ok: true, error: null);
      return (ok: false, error: _parseErrorBody(response.body));
    } catch (e) {
      return (ok: false, error: e.toString());
    }
  }

  Future<({bool ok, String? error})> deletePhoto({
    required String photoId,
  }) async {
    try {
      final headers = await AuthHttpHeaders.bearerJson();
      if (headers == null) {
        return (ok: false, error: 'Нет авторизации');
      }
      final url = Uri.parse('$kApiBaseUrl/api/SalonPhotos/delete-photo/$photoId');
      final response = await http.delete(
        url,
        headers: headers,
      );
      if (response.statusCode == 200) return (ok: true, error: null);
      return (ok: false, error: _parseErrorBody(response.body));
    } catch (e) {
      return (ok: false, error: e.toString());
    }
  }

  String? _parseErrorBody(String body) {
    final t = body.trim();
    if (t.isEmpty) return null;
    try {
      final d = json.decode(t);
      if (d is String) return d;
      if (d is Map) {
        return d['error']?.toString() ??
            d['title']?.toString() ??
            d['message']?.toString() ??
            d['detail']?.toString();
      }
    } catch (_) {}
    return t.length > 200 ? '${t.substring(0, 200)}…' : t;
  }
}
