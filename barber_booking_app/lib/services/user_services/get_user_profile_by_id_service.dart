import 'dart:convert';

import 'package:barber_booking_app/config/api_config.dart';
import 'package:barber_booking_app/models/user_models/responses/user_profile_by_id_response.dart';
import 'package:barber_booking_app/services/auth_services/auth_http_headers.dart';
import 'package:http/http.dart' as http;

class GetUserProfileByIdService {
  Future<UserProfileByIdResponse?> getProfile(String userId) async {
    try {
      final headers = await AuthHttpHeaders.jsonWithOptionalBearer();

      final url = Uri.parse('$kApiBaseUrl/api/Users/get_user_profile/$userId');
      final response = await http.get(
        url,
        headers: headers,
      );
      if (response.statusCode == 200) {
        final map = json.decode(response.body);
        if (map is Map<String, dynamic>) {
          return UserProfileByIdResponse.fromJson(map);
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
