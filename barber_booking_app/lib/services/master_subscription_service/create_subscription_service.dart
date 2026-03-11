import 'dart:convert';

import 'package:barber_booking_app/models/master_subscription_models/request/create_subscription_request.dart';
import 'package:http/http.dart' as http;
class CreateSubscriptionService {
  final String baseUrl = 'http://192.168.0.100:5088';
  Future<String?> createSubscription(CreateSubscriptionRequest request, String? token) async{
    try{
     final url = Uri.parse('$baseUrl/api/MasterSubscriptions/Create-MasterSubscription');
     final response = await http.post(
        url,
        headers: 
        {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        },
        body: json.encode(request.toJson())
        );
        print('📥 Статус: ${response.statusCode}');
        print('📥 Ответ: ${response.body}');

        if (response.statusCode == 200) {
          return json.decode(response.body); 
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