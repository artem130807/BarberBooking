import 'dart:convert';

import 'package:barber_booking_app/models/review_models/request/update_review_request.dart';
import 'package:http/http.dart' as http;
import 'package:barber_booking_app/config/api_config.dart';
class UpdateReviewUserService {

  Future<bool?> updateReview(String? id ,UpdateReviewRequest request) async{
    try{
      final url = Uri.parse('$kApiBaseUrl/api/Review/UpdateReview/$id');
      final requestBody = json.encode(request.toJson());
      final response = await http.patch(url, headers: {'Content-Type': 'application/json',},
      body: requestBody,
      );
      print('📥 Статус: ${response.statusCode}');
      print('📥 Ответ: ${response.body}');
      if (response.statusCode == 200) {
        print('📊 Успешное обновление');
        return true;
      }else{
        print("Ошибка при обновлении");
        return false;
      }
    }catch(e){
      print(e);
      return false;
    }
  }
}