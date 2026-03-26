import 'dart:convert';

import 'package:barber_booking_app/models/master_models/response/get_the_best_masters_response.dart';
import 'package:http/http.dart' as http;
import 'package:barber_booking_app/config/api_config.dart';
class GetTheBestMastersService {

  Future<List<GetTheBestMastersResponse>?> getMasters(int? take, String? token) async {
    try{
       final url = Uri.parse('$kApiBaseUrl/api/MasterProfile/GetTheBestMasters${take != null ? '?take=$take' : ''}');
       final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
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
        return jsonList.map((json) => GetTheBestMastersResponse.fromJson(json)).toList();
      }
    }catch(e){
      print(e);
      return null;
    }

  }
}