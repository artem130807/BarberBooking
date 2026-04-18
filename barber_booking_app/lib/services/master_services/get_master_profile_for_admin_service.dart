import 'dart:convert';

import 'package:barber_booking_app/config/api_config.dart';
import 'package:barber_booking_app/models/master_models/response/master_profile_info_for_admin_response.dart';
import 'package:barber_booking_app/services/auth_services/auth_http_headers.dart';
import 'package:http/http.dart' as http;

class GetMasterProfileForAdminService {
  Future<MasterProfileInfoForAdminResponse?> getProfile(
    String masterId,
  ) async {
    try {
      final headers = await AuthHttpHeaders.bearerJson();
      if (headers == null) return null;

      final url = Uri.parse(
        '$kApiBaseUrl/api/MasterProfile/GetMasterProfileByIdForAdmin/$masterId',
      );
      final response = await http.get(
        url,
        headers: headers,
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
