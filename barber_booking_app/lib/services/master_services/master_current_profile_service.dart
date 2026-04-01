import 'dart:convert';

import 'package:barber_booking_app/config/api_config.dart';
import 'package:barber_booking_app/models/master_models/response/get_master_response.dart';
import 'package:http/http.dart' as http;

class MasterCurrentProfileService {
  Future<GetMasterResponse?> fetch(String? token) async {
    if (token == null || token.isEmpty) return null;
    try {
      final url = Uri.parse(
        '$kApiBaseUrl/api/MasterProfile/GetMasterProfileForCurrentUser',
      );
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        final map = json.decode(response.body) as Map<String, dynamic>;
        return GetMasterResponse.fromJson(map);
      }
      return null;
    } catch (_) {
      return null;
    }
  }
}
