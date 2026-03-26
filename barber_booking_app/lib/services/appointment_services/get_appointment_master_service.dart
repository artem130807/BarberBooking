import 'dart:convert';

import 'package:barber_booking_app/models/appointment_models/response/get_appointment_master_response.dart';
import 'package:http/http.dart' as http;
import 'package:barber_booking_app/config/api_config.dart';
class GetAppointmentMasterService {

   Future<GetAppointmentMasterResponse?> getMaster(String? Id) async{
     try{
      final url = Uri.parse('$kApiBaseUrl/api/Appointment/get-appointmentMasterById/$Id');
      
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