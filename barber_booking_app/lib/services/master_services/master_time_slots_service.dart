import 'dart:convert';

import 'package:barber_booking_app/config/api_config.dart';
import 'package:barber_booking_app/models/master_interface_models/request/create_time_slot_request.dart';
import 'package:barber_booking_app/models/master_interface_models/response/get_master_time_slot_response.dart';
import 'package:barber_booking_app/services/auth_services/auth_session_binding.dart';
import 'package:http/http.dart' as http;

class MasterTimeSlotsService {
  String _dateOnly(DateTime d) {
    final y = d.year.toString().padLeft(4, '0');
    final m = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    return '$y-$m-$day';
  }

  Map<String, String> _headers(String token) => {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

  Future<List<GetMasterTimeSlotResponse>?> fetchForDate({
    required String masterId,
    required DateTime date,
  }) async {
    final token = await AuthSessionBinding.instance.accessToken();
    if (token == null || token.isEmpty || masterId.isEmpty) return null;
    try {
      final url = Uri.parse(
        '$kApiBaseUrl/api/MasterTimeSlot/get-slotByMasterId$masterId?date=${_dateOnly(date)}',
      );
      final response = await http.get(url, headers: _headers(token));
      if (response.statusCode != 200) return null;
      final decoded = json.decode(response.body);
      if (decoded is! List) return null;
      return decoded
          .map((e) => GetMasterTimeSlotResponse.fromJson(
                Map<String, dynamic>.from(e as Map),
              ))
          .toList();
    } catch (_) {
      return null;
    }
  }

  Future<GetMasterTimeSlotResponse?> fetchById({
    required String slotId,
  }) async {
    final token = await AuthSessionBinding.instance.accessToken();
    if (token == null || token.isEmpty || slotId.isEmpty) return null;
    try {
      final url = Uri.parse(
        '$kApiBaseUrl/api/MasterTimeSlot/get-slotById$slotId',
      );
      final response = await http.get(url, headers: _headers(token));
      if (response.statusCode != 200) return null;
      final map = json.decode(response.body) as Map<String, dynamic>;
      return GetMasterTimeSlotResponse.fromJson(map);
    } catch (_) {
      return null;
    }
  }

  Future<bool> deleteSlot({
    required String slotId,
  }) async {
    final token = await AuthSessionBinding.instance.accessToken();
    if (token == null || token.isEmpty || slotId.isEmpty) return false;
    try {
      final url = Uri.parse(
        '$kApiBaseUrl/api/MasterTimeSlot/delete-timeSlot$slotId',
      );
      final response = await http.delete(url, headers: _headers(token));
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  Future<String?> createSlot({
    required CreateTimeSlotRequest body,
  }) async {
    final token = await AuthSessionBinding.instance.accessToken();
    if (token == null || token.isEmpty) return 'Нужна авторизация';
    try {
      final url = Uri.parse('$kApiBaseUrl/api/MasterTimeSlot/create-timeSlot');
      final response = await http.post(
        url,
        headers: _headers(token),
        body: json.encode(body.toJson()),
      );
      if (response.statusCode == 200) return null;
      final raw = response.body;
      if (raw.isEmpty) return 'Не удалось создать слот';
      try {
        final m = json.decode(raw);
        if (m is Map && m['error'] != null) return m['error'].toString();
      } catch (_) {}
      return raw.length > 200 ? 'Не удалось создать слот' : raw;
    } catch (_) {
      return 'Ошибка сети';
    }
  }
}
