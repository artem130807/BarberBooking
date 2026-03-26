import 'dart:convert';

import 'package:barber_booking_app/models/appointment_models/request/create_appointment_request.dart';
import 'package:http/http.dart' as http;
import 'package:barber_booking_app/config/api_config.dart';
class CreateAppointmentService{

 Future<bool> createAppointment(CreateAppointmentRequest? request, String? token) async{
  if (request == null || token == null || token.isEmpty) {
    return false;
  }

  try{
     final url = Uri.parse('$kApiBaseUrl/api/Appointment/create-appointment');
     final response = await http.post(
        url,
        headers: 
        {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        },
        body: jsonEncode(request.toJson()),
        );
        print('📥 Статус: ${response.statusCode}');
        print('📥 Ответ: ${response.body}');

        if (response.statusCode == 200) {
        return true;
        } else {
        print('❌ Ошибка сервера: ${response.body}');
        return false;
        }
  }catch(e){
    print(e);
    return false;
  }
 }
}