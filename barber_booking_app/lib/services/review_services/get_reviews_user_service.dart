import 'dart:convert';

import 'package:barber_booking_app/config/api_config.dart';
import 'package:barber_booking_app/models/params/page_params.dart';
import 'package:barber_booking_app/models/review_models/response/get_reviews_user_response.dart';
import 'package:barber_booking_app/services/auth_services/auth_http_headers.dart';
import 'package:http/http.dart' as http;

class GetReviewsUserService {
  Future<List<GetReviewsUserResponse>?> getReviews(
    PageParams pageParams,
  ) async {
    try {
      final headers = await AuthHttpHeaders.bearerJson();
      if (headers == null) return null;

      final url = Uri.parse(
        '$kApiBaseUrl/api/Review/GetReviewsByClientId',
      ).replace(
        queryParameters: {
          'page': pageParams.Page.toString(),
          'pageSize': pageParams.PageSize.toString(),
        },
      );

      final response = await http.get(url, headers: headers);

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
        return jsonList
            .map((json) => GetReviewsUserResponse.fromJson(json))
            .toList();
      } else {
        print('❌ Ошибка сервера: ${response.body}');
        try {
          final errorJson = json.decode(response.body);
          throw Exception(errorJson['error'] ?? 'Неизвестная ошибка');
        } catch (e) {
          throw Exception('Ошибка сервера: ${response.statusCode}');
        }
      }
    } catch (e) {
      print('🔥 Исключение: $e');
      return null;
    }
  }
}
