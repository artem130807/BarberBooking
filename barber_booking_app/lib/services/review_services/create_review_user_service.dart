import 'dart:convert';
import 'package:barber_booking_app/models/review_models/request/create_review_request.dart';
import 'package:http/http.dart' as http;
class CreateReviewUserService {
  final String baseUrl = 'http://192.168.0.100:5088';
  Future<bool> createReview(CreateReviewRequest request, String? token) async{
    try{
      final url = Uri.parse('$baseUrl/api/Review/Create-Review');
      final requestBody = json.encode(request.toJson());
      final response = await http.post(url, headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token'
        },
      body: requestBody,
      );
      print('📥 Статус: ${response.statusCode}');
      print('📥 Ответ: ${response.body}');
      if (response.statusCode == 200) {
        print('📊 Успешное добавление');
        return true;
      }else{
        print("Ошибка при добавлении");
        return false;
      }
    }catch(e){
      print(e);
      return false;
    }
  }
}