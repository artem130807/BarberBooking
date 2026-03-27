import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:barber_booking_app/config/api_config.dart';
import 'package:barber_booking_app/models/time_slot_models/request/get_slots_request.dart';
import 'package:barber_booking_app/models/time_slot_models/response/get_available_slots.dart';
import 'package:http/http.dart' as http;

class GetSlotsService {
  static const Duration _requestTimeout = Duration(seconds: 30);

  Future<List<GetAvailableSlots>?> getSlots(String? masterId, GetSlotsRequest request) async {
    try {
      final id = masterId?.trim() ?? '';
      if (id.isEmpty) {
        return null;
      }
      final dateStr = request.DateTime?.trim();
      final durationStr = request.ServiceDuration?.trim();
      if (dateStr == null ||
          dateStr.isEmpty ||
          durationStr == null ||
          durationStr.isEmpty) {
        throw Exception('Нет даты или длительности услуги для запроса слотов');
      }
      final base = Uri.parse(kApiBaseUrl);
      final path =
          '${base.path.endsWith('/') ? base.path.substring(0, base.path.length - 1) : base.path}'
          '/api/MasterTimeSlot/get-availableSlots/$id';
      final url = base.replace(
        path: path,
        queryParameters: <String, String>{
          'date': dateStr,
          'serviceDuration': durationStr,
        },
      );
      if (kDebugMode) {
        debugPrint('[GetSlotsService] GET $url');
      }
      final response = await http
          .get(
            url,
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(_requestTimeout);

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        if (decoded is! List) {
          return null;
        }
        final jsonList = decoded;
        if (jsonList.isEmpty) {
          return [];
        }
        return jsonList
            .map((e) => GetAvailableSlots.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList();
      }
      try {
        final errorJson = json.decode(response.body);
        throw Exception(errorJson['error'] ?? 'Ошибка сервера: ${response.statusCode}');
      } catch (_) {
        throw Exception('Ошибка сервера: ${response.statusCode}');
      }
    } on TimeoutException {
      throw Exception('Превышено время ожидания сервера');
    } on SocketException catch (e) {
      throw Exception(_humanReadableNetworkError(e));
    } catch (e) {
      final msg = e.toString();
      if (msg.contains('Connection refused') ||
          msg.contains('ClientException') ||
          msg.contains('Failed host lookup')) {
        throw Exception(_humanReadableNetworkError(e));
      }
      if (e is Exception) rethrow;
      throw Exception(e.toString());
    }
  }

  static String _humanReadableNetworkError(Object e) {
    final t = e.toString();
    if (t.contains('Connection refused')) {
      return 'Сервер не отвечает (connection refused). Запустите API и проверьте API_BASE_URL / kApiBaseUrl (порт обычно 5088).';
    }
    if (t.contains('Failed host lookup')) {
      return 'Не удалось найти хост. Проверьте адрес API.';
    }
    return 'Ошибка сети: проверьте Wi‑Fi и доступность сервера.';
  }
}
