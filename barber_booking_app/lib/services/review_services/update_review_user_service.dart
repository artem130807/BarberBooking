import 'dart:convert';

import 'package:barber_booking_app/models/review_models/request/update_review_request.dart';
import 'package:http/http.dart' as http;
class UpdateReviewUserService {
  final String baseUrl = 'http://192.168.0.100:5088';
  Future<bool?> updateReview(String? id ,UpdateReviewRequest request) async{
    try{
      final url = Uri.parse('$baseUrl/api/Review/UpdateReview/$id');
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