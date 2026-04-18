import 'dart:convert';

import 'package:barber_booking_app/config/api_config.dart';
import 'package:barber_booking_app/models/master_models/response/get_the_best_masters_response.dart';
import 'package:barber_booking_app/services/auth_services/auth_http_headers.dart';
import 'package:http/http.dart' as http;

class GetTheBestMastersService {
  Future<List<GetTheBestMastersResponse>?> getMasters(int? take) async {
    try {
      final url = Uri.parse(
        '$kApiBaseUrl/api/MasterProfile/GetTheBestMasters${take != null ? '?take=$take' : ''}',
      );
      final headers = await AuthHttpHeaders.jsonWithOptionalBearer();
      final response = await http.get(
        url,
        headers: headers,
      );
      print('📥 Статус: ${response.statusCode}');
      print('📥 Ответ: ${response.body}');
      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        print('📊 Количество Мастеров: ${jsonList.length}');
        if (jsonList.isEmpty) {
          print('⚠️ Сервер вернул пустой список');
          return [];
        }
        return jsonList
            .map((json) => GetTheBestMastersResponse.fromJson(json))
            .toList();
      }
    } catch (e) {
      print(e);
      return null;
    }
  }
}
