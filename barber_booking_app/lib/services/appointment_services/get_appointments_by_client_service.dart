import 'dart:convert';

import 'package:barber_booking_app/models/appointment_models/response/get_appointments_by_client_response.dart';
import 'package:http/http.dart' as http;

class GetAppointmentsByClientService {
  final String baseUrl = 'http://192.168.0.100:5088';
  Future<List<GetAppointmentsByClientResponse>?> getAppointments(String? token) async{
     try {
       
        final url = Uri.parse('$baseUrl/api/Appointment/get-appointmentsByClientId');

        final response = await http.get(url, headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
          });

        print('📥 Статус: ${response.statusCode}');
        print('📥 Ответ: ${response.body}');
        
        if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        print('📊 Количество записей: ${jsonList.length}');
        if (jsonList.isEmpty) {
          print('⚠️ Сервер вернул пустой список');
          return [];
        }
        return jsonList.map((json) => GetAppointmentsByClientResponse.fromJson(json)).toList();
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