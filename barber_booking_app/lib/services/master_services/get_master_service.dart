import 'dart:convert';

import 'package:barber_booking_app/config/api_config.dart';
import 'package:barber_booking_app/models/master_models/response/get_master_response.dart';
import 'package:barber_booking_app/services/auth_services/auth_http_headers.dart';
import 'package:http/http.dart' as http;

class GetMasterService {
  Future<GetMasterResponse?> getMaster(String? id) async {
    try {
      final url =
          Uri.parse('$kApiBaseUrl/api/MasterProfile/GetMasterProfileById/$id');

      final headers = await AuthHttpHeaders.jsonWithOptionalBearer();

      final response = await http.get(
        url,
        headers: headers,
      );
      print('📥 Статус: ${response.statusCode}');
      print('📥 Ответ: ${response.body}');

      if (response.statusCode == 200) {
        return GetMasterResponse.fromJson(json.decode(response.body));
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
