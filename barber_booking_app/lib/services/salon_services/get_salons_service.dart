import 'dart:convert';
import 'package:barber_booking_app/models/params/page_params.dart';
import 'package:barber_booking_app/models/params/salon_params/salon_filter.dart';
import 'package:barber_booking_app/models/salon_models/response/get_salons_response.dart';
import 'package:http/http.dart' as http;
class GetSalonsService {
  final String baseUrl = 'http://192.168.0.100:5088';

  Future<List<GetSalonsResponse>?> getSalons(PageParams params, SalonFilter filter ,String? token) async{
      try {
        print('📦 Получен запрос: параметры ${params.Page}, ${params.PageSize}');

        final url = Uri.parse('$baseUrl/api/Salon/GetSalonsByFilter').replace(
          queryParameters: {
            'page':params.Page.toString(),
            'pageSize':params.PageSize.toString()
          }
        ).replace(queryParameters: {
          'isActive':filter.IsActive.toString(),
          'maxRating':filter.MaxRating.toString(),
          'popular':filter.Popular.toString(),
          'minPrice':filter.MinPrice.toString()
        });
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
        final List<dynamic> jsonList = json.decode(response.body);
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