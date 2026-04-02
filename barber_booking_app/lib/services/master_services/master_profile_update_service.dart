import 'dart:convert';

import 'package:barber_booking_app/config/api_config.dart';
import 'package:barber_booking_app/models/master_interface_models/request/update_master_profile_request.dart';
import 'package:barber_booking_app/models/master_models/response/get_master_response.dart';
import 'package:http/http.dart' as http;

class MasterProfileUpdateService {
  Future<GetMasterResponse?> patch({
    required String? token,
    required String masterId,
    required UpdateMasterProfileRequest body,
  }) async {
    if (token == null || token.isEmpty) return null;
    try {
      final url = Uri.parse(
        '$kApiBaseUrl/api/MasterProfile/UpdateMasterProfile$masterId',
      );
      final response = await http.patch(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(body.toJson()),
      );
      if (response.statusCode != 200) return null;
      final map = json.decode(response.body) as Map<String, dynamic>;
      return GetMasterResponse.fromJson(map);
    } catch (_) {
      return null;
    }
  }
}
