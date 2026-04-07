import 'dart:convert';

import 'package:barber_booking_app/models/service_models/response/get_services_response.dart';
import 'package:http/http.dart' as http;
import 'package:barber_booking_app/config/api_config.dart';
class GetServicesService {

  Future<List<GetServicesResponse>?> getServices(String? salonId) async{
       try {
        if (salonId == null || salonId.isEmpty) {
          print('❌ salonId is null or empty');
          return null;
        }
        print(salonId);
        final url = Uri.parse('$kApiBaseUrl/api/Services/get-serviceBySalon/$salonId');
        final response = await http.get(url, headers: {'Content-Type': 'application/json'},);
        print('📥 Статус: ${response.statusCode}');
        print('📥 Ответ: ${response.body}');
        
        if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        print('📊 Количество отзывов: ${jsonList.length}');
        if (jsonList.isEmpty) {
          print('⚠️ Сервер вернул пустой список');
          return [];
        }
        return jsonList.map((json) => GetServicesResponse.fromJson(json)).toList();
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

  Future<List<GetServicesResponse>?> getServicesForMasterBooking(
    String? masterProfileId,
  ) async {
    try {
      if (masterProfileId == null || masterProfileId.isEmpty) return null;
      final url = Uri.parse(
        '$kApiBaseUrl/api/MasterServices/get-services-for-booking-by-master/$masterProfileId',
      );
      final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode != 200) return null;
      final decoded = json.decode(response.body);
      if (decoded is! List) return null;
      if (decoded.isEmpty) return [];
      return decoded
          .map((e) => GetServicesResponse.fromJson(
                Map<String, dynamic>.from(e as Map),
              ))
          .toList();
    } catch (_) {
      return null;
    }
  }
}