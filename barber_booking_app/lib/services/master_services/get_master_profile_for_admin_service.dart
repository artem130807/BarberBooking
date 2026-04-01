import 'dart:convert';

import 'package:barber_booking_app/config/api_config.dart';
import 'package:barber_booking_app/models/master_models/response/master_profile_info_for_admin_response.dart';
import 'package:http/http.dart' as http;

/// `GET /api/MasterProfile/GetMasterProfileByIdForAdmin/{id}` — DTO для администратора.
class GetMasterProfileForAdminService {
  Future<MasterProfileInfoForAdminResponse?> getProfile(
    String masterId,
    String? token,
  ) async {
    try {
      final url = Uri.parse(
        '$kApiBaseUrl/api/MasterProfile/GetMasterProfileByIdForAdmin/$masterId',
      );
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          if (token != null && token.isNotEmpty)
            'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        if (decoded is Map<String, dynamic>) {
          return MasterProfileInfoForAdminResponse.fromJson(decoded);
        }
      }
      return null;
    } catch (_) {
      return null;
    }
  }
}
