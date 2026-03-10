import 'dart:convert';

import 'package:barber_booking_app/models/service_models/response/get_services_response.dart';
import 'package:http/http.dart' as http;
class GetServicesService {
  final String baseUrl = 'http://192.168.0.100:5088';
  Future<List<GetServicesResponse>?> getServices(String? salonId) async{
       try {
        if (salonId == null || salonId.isEmpty) {
          print('❌ salonId is null or empty');
          return null;
        }
        print(salonId);
        final url = Uri.parse('$baseUrl/api/Services/get-serviceBySalon/$salonId');
        final response = await http.get(url, headers: {'Content-Type': 'application/json'},);
        print('📥 Статус: ${response.statusCode}');
        print('📥 Ответ: ${response.body}');
        
        if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        print('📊 Количество отзывов: ${jsonList.length}');
        if (jsonList.isEmpty) {
          print('⚠️ Сервер вернул пустой список');
          return [];
        }
        return jsonList.map((json) => GetServicesResponse.fromJson(json)).toList();
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