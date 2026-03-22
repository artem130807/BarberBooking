import 'dart:convert';

import 'package:barber_booking_app/models/appointment_models/response/get_appointment_master_response.dart';
import 'package:http/http.dart' as http;
class GetAppointmentMasterService {
  final String baseUrl = 'http://192.168.0.100:5088';
   Future<GetAppointmentMasterResponse?> getMaster(String? Id) async{
     try{
      final url = Uri.parse('$baseUrl/api/Appointment/get-appointmentMasterById/$Id');
      
      final response = await http.get(
      url,
        headers: {
          'Content-Type': 'application/json'
        }
      );
      print('📥 Статус: ${response.statusCode}');
      print('📥 Ответ: ${response.body}');
      
      if (response.statusCode == 200) {
        return GetAppointmentMasterResponse.fromJson(json.decode(response.body));
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