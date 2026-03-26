import 'dart:convert';

import 'package:barber_booking_app/models/params/page_params.dart';
import 'package:barber_booking_app/models/params/review_params/review_sort_params.dart';
import 'package:barber_booking_app/models/review_models/response/get_reviews_master_response.dart';
import 'package:http/http.dart' as http;
import 'package:barber_booking_app/config/api_config.dart';
class GetReviewsMasterService {

  Future<List<GetReviewsMasterResponse>?> getReviewsMaster(String? masterId, PageParams pageParams, ReviewSortParams sort) async{
     try {

        final url = Uri.parse('$kApiBaseUrl/api/Review/GetReviewsByMasterIdSort/$masterId').replace(
          queryParameters: {
          'page':pageParams.Page.toString(),
          'pageSize':pageParams.PageSize.toString()
          }
        ).replace(
        queryParameters: {
          'orderBy':sort.OrderBy.toString(),
          'orderbyDescending':sort.OrderbyDescending.toString()
        });
        
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