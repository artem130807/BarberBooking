import 'package:barber_booking_app/models/SalonModels/request/get_salon_request.dart';
import 'package:barber_booking_app/models/SalonModels/response/get_salon_response.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
class GetSalonService {
  final String baseUrl = 'http://192.168.0.100:5088';

  Future<GetSalonResponse?> getSalon(String? Id) async{
    try{
      final url = Uri.parse('$baseUrl/api/Salon/GetSalonById/$Id');
      
      final response = await http.get(
      url,
        headers: {
          'Content-Type': 'application/json'
        }
      );
      print('📥 Статус: ${response.statusCode}');
      print('📥 Ответ: ${response.body}');
      
      if (response.statusCode == 200) {
        return GetSalonResponse.fromJson(json.decode(response.body));
      } else {
        print('❌ Ошибка сервера: ${response.body}');
        return null;
      }
    }catch(e){
      print(e);
      return null;
    }
  }
}