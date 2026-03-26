import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:barber_booking_app/models/service_models/response/get_service_search_response.dart';
import 'package:barber_booking_app/config/api_config.dart';

class GetServiceSearchService {

     Future<List<GetServiceSearchResponse>?> getServices(String? token) async{
       try {
        final url = Uri.parse('$kApiBaseUrl/api/Services/get-services-by-startWith');
        final response = await http.get(url, headers: 
        {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        },);
        print('📥 Статус: ${response.statusCode}');
        print('📥 Ответ: ${response.body}');
        
        if (response.statusCode == 200) {
          final Map<String, dynamic> jsonResponse = json.decode(response.body);
          final List<dynamic> jsonList = jsonResponse['data'];
        print('📊 Количество услуг: ${jsonList.length}');
        if (jsonList.isEmpty) {
          print('⚠️ Сервер вернул пустой список');
          return [];
        }
        return jsonList.map((json) => GetServiceSearchResponse.fromJson(json)).toList();
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