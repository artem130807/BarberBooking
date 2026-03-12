import 'dart:convert';

import 'package:barber_booking_app/models/user_models/responses/get_user_response.dart';
import 'package:http/http.dart' as http;
class GetUserService {
   final String baseUrl = 'http://192.168.0.100:5088';

  Future<GetUserResponse?> getUser(String? token) async{
    try{
      final url = Uri.parse('$baseUrl/api/Users/get-user-by-token-id');
      
      final response = await http.get(
      url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        }
      );
      print('📥 Статус: ${response.statusCode}');
      print('📥 Ответ: ${response.body}');
      
      if (response.statusCode == 200) {
        return GetUserResponse.fromJson(json.decode(response.body));
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