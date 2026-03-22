import 'dart:convert';
import 'package:barber_booking_app/models/appointment_models/response/get_appointment_client_response.dart';
import 'package:http/http.dart' as http;

class GetAppointmentClientService {
  final String baseUrl = 'http://192.168.0.100:5088';

  Future<GetAppointmentClientResponse?> getAppointmentById(String appointmentId, String token) async {
    try {
      final url = Uri.parse('$baseUrl/api/Appointment/get-appointmentClientById/$appointmentId');

      final response = await http.get(url, headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      });

      print('📥 Статус: ${response.statusCode}');
      print('📥 Ответ: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        return GetAppointmentClientResponse.fromJson(jsonData);
      } else {
        print('❌ Ошибка сервера: ${response.body}');
        throw Exception('Ошибка сервера: ${response.statusCode}');
      }
    } catch (e) {
      print('🔥 Исключение: $e');
      return null;
    }
  }
}
