import 'dart:convert';

import 'package:barber_booking_app/config/api_config.dart';
import 'package:barber_booking_app/models/review_models/request/update_review_request.dart';
import 'package:barber_booking_app/services/auth_services/auth_http_headers.dart';
import 'package:http/http.dart' as http;

class UpdateReviewUserService {
  Future<bool?> updateReview(String? id, UpdateReviewRequest request) async {
    try {
      final headers = await AuthHttpHeaders.bearerJson();
      if (headers == null) return false;

      final url = Uri.parse('$kApiBaseUrl/api/Review/UpdateReview/$id');
      final requestBody = json.encode(request.toJson());
      final response = await http.patch(
        url,
        headers: headers,
        body: requestBody,
      );
      print('📥 Статус: ${response.statusCode}');
      print('📥 Ответ: ${response.body}');
      if (response.statusCode == 200) {
        print('📊 Успешное обновление');
        return true;
      } else {
        print('Ошибка при обновлении');
        return false;
      }
    } catch (e) {
      print(e);
      return false;
    }
  }
}
