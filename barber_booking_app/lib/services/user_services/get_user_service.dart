import 'dart:convert';

import 'package:barber_booking_app/config/api_config.dart';
import 'package:barber_booking_app/models/user_models/responses/get_user_response.dart';
import 'package:barber_booking_app/services/auth_services/auth_session_binding.dart';
import 'package:http/http.dart' as http;

class GetUserService {
  Future<GetUserResponse?> getUser() async {
    try {
      final token = await AuthSessionBinding.instance.accessToken();
      if (token == null || token.isEmpty) return null;
      final url = Uri.parse('$kApiBaseUrl/api/Users/get-user-by-token-id');

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        },
      );
      print('📥 Статус: ${response.statusCode}');
      print('📥 Ответ: ${response.body}');

      if (response.statusCode == 200) {
        return GetUserResponse.fromJson(json.decode(response.body));
      } else {
        print('❌ Ошибка сервера: ${response.body}');
        return null;
      }
    } catch (e) {
      print(e);
      return null;
    }
  }
}
