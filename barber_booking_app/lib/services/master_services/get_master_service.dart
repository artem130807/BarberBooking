import 'dart:convert';

import 'package:barber_booking_app/models/master_models/response/get_master_response.dart';
import 'package:http/http.dart' as http;
import 'package:barber_booking_app/config/api_config.dart';
class GetMasterService {

  /// [token] нужен, чтобы API вернул персональное поле [isSubscripe] (подписка текущего пользователя).
  Future<GetMasterResponse?> getMaster(String? Id, {String? token}) async{
     try{
      final url = Uri.parse('$kApiBaseUrl/api/MasterProfile/GetMasterProfileById/$Id');

      final headers = <String, String>{
        'Content-Type': 'application/json',
      };
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }

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
    }catch(e){
      print(e);
      return null;
    }
  }
}