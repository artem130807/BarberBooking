import 'dart:convert';

import 'package:barber_booking_app/models/master_models/response/get_master_response.dart';
import 'package:http/http.dart' as http;
import 'package:barber_booking_app/config/api_config.dart';
class GetMasterService {

  Future<GetMasterResponse?> getMaster(String? Id) async{
     try{
      final url = Uri.parse('$kApiBaseUrl/api/MasterProfile/GetMasterProfileById/$Id');
      
      final response = await http.get(
      url,
        headers: {
          'Content-Type': 'application/json'
        }
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