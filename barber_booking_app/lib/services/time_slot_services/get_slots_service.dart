import 'dart:convert';
import 'package:barber_booking_app/models/time_slot_models/request/get_slots_request.dart';
import 'package:barber_booking_app/models/time_slot_models/response/get_available_slots.dart';
import 'package:http/http.dart' as http;
class GetSlotsService {
final String baseUrl = 'http://192.168.0.100:5088';
Future<List<GetAvailableSlots>?> getSlots(String? masterId, GetSlotsRequest request) async{
 try {
        if (masterId == null || masterId.isEmpty) {
          print('❌ salonId is null or empty');
          return null;
        }
        print(masterId);
        final url = Uri.parse('$baseUrl/api/MasterTimeSlot/get-availableSlots/$masterId').replace(queryParameters: {
          'date': request.DateTime,
          'serviceDuration': request.ServiceDuration,
        });
        final response = await http.get(url, headers: {'Content-Type': 'application/json'},);
        print('📥 Статус: ${response.statusCode}');
        print('📥 Ответ: ${response.body}');
        
        if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        print('📊 Количество доступных слотов: ${jsonList.length}');
        if (jsonList.isEmpty) {
          print('⚠️ Сервер вернул пустой список');
          return [];
        }
        return jsonList.map((json) => GetAvailableSlots.fromJson(json)).toList();
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
