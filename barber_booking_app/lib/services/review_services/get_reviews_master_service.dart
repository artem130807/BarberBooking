import 'dart:convert';

import 'package:barber_booking_app/models/params/page_params.dart';
import 'package:barber_booking_app/models/review_models/response/get_reviews_master_response.dart';
import 'package:http/http.dart' as http;
class GetReviewsMasterService {
  final String baseUrl = 'http://192.168.0.100:5088';
  Future<List<GetReviewsMasterResponse>?> getReviewsMaster(String? masterId, PageParams pageParams) async{
     try {

        final url = Uri.parse('$baseUrl/api/Review/GetReviewsByMasterId/$masterId').replace(
           queryParameters: {
            'page':pageParams.Page.toString(),
            'pageSize':pageParams.PageSize.toString()
          }
        );
        
        final response = await http.get(url, headers: {'Content-Type': 'application/json'},);
        
        print('📥 Статус: ${response.statusCode}');
        print('📥 Ответ: ${response.body}');
        
        if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        final List<dynamic> jsonList = jsonResponse['data'];
        print('📊 Количество отзывов: ${jsonList.length}');
        if (jsonList.isEmpty) {
          print('⚠️ Сервер вернул пустой список');
          return [];
        }
        return jsonList.map((json) => GetReviewsMasterResponse.fromJson(json)).toList();
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