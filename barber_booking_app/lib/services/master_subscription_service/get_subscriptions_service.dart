import 'dart:convert';

import 'package:barber_booking_app/models/master_subscription_models/response/get_subscriptions_response.dart';
import 'package:http/http.dart' as http;
class GetSubscriptionsService {
  final String baseUrl = 'http://192.168.0.100:5088';
  Future<List<GetSubscriptionsResponse>?> getSubscriptions(String? token) async{
    try{
      
      final url = Uri.parse('$baseUrl/api/MasterSubscriptions/Get-MasterSubscriptions');

        final response = await http.get(url, headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
          });

        print('📥 Статус: ${response.statusCode}');
        print('📥 Ответ: ${response.body}');
        
        if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        print('📊 Количество данных: ${jsonList.length}');
        if (jsonList.isEmpty) {
          print('⚠️ Сервер вернул пустой список');
          return [];
        }
        return jsonList.map((json) => GetSubscriptionsResponse.fromJson(json)).toList();
        } else {
        print('❌ Ошибка сервера: ${response.body}');
        try {
        final errorJson = json.decode(response.body);
        throw Exception(errorJson['error'] ?? 'Неизвестная ошибка');
        } catch (e) {
        throw Exception('Ошибка сервера: ${response.statusCode}');
        }
        }
        } catch(e) {
        print('🔥 Исключение: $e');
        return null;
      } 
  }
}