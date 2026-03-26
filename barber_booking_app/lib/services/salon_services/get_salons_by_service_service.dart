import 'dart:convert';

import 'package:barber_booking_app/models/params/page_params.dart';
import 'package:barber_booking_app/models/salon_models/response/get_salons_response.dart';
import 'package:http/http.dart' as http;
import 'package:barber_booking_app/config/api_config.dart';
class GetSalonsByServiceService {

     Future<List<GetSalonsResponse>?> GetSalons(String? serviceName ,PageParams params, String? token) async{
      try {
        print('📦 Получен запрос: параметры ${params.Page}, ${params.PageSize}');

        final url = Uri.parse('$kApiBaseUrl/api/Salon/GetSalonsByServiceName').replace(
          queryParameters: {
            'serviceName':serviceName.toString(),
            'page':params.Page.toString(),
            'pageSize':params.PageSize.toString()
          }
        );
        print('🌐 URL: $url');
        
        final requestBody = json.encode(params.toJson());
        print('📤 Отправляю: $requestBody');
        
        final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        );
        
        print('📥 Статус: ${response.statusCode}');
        print('📥 Ответ: ${response.body}');
        
        if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        final List<dynamic> jsonList = jsonResponse['data'];
        print('📊 Количество салонов: ${jsonList.length}');
        if (jsonList.isEmpty) {
          print('⚠️ Сервер вернул пустой список');
          return [];
        }
        return jsonList.map((json) => GetSalonsResponse.fromJson(json)).toList();
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