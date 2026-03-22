import 'dart:convert';

import 'package:barber_booking_app/models/messages_models/response/get_message_user_response.dart';
import 'package:http/http.dart' as http;
class GetMessageUserService {
  final String baseUrl = 'http://192.168.0.100:5088';
  Future<List<GetMessageUserResponse>?> getMessages(String? token) async{
    try{
        final url = Uri.parse('$baseUrl/api/Message/get-messages');
        final response = await http.get(
        url,
        headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token'
        },
      );
      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        if (jsonList.isEmpty) return [];
        return jsonList.map((json) => GetMessageUserResponse.fromJson(json)).toList();
      }
    }catch(e){
      print(e);
      return null;
    }
  }
}