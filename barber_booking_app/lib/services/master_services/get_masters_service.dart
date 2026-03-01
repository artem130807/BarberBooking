import 'dart:convert';

import 'package:barber_booking_app/models/master_models/response/get_masters_response.dart';
import 'package:http/http.dart' as http;
class GetMastersService {
  final String baseUrl = 'http://192.168.0.100:5088';
  Future<List<GetMastersResponse>?> getMasters(String? salonId) async {
    try{
       final url = Uri.parse('$baseUrl/api/MasterProfile/GetMastersBySalon/$salonId');
       final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        );
        print('📥 Статус: ${response.statusCode}');
        print('📥 Ответ: ${response.body}');
        if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        print('📊 Количество Мастеров в салоне: ${jsonList.length}');
        if (jsonList.isEmpty) {
          print('⚠️ Сервер вернул пустой список');
          return [];
        }
        return jsonList.map((json) => GetMastersResponse.fromJson(json)).toList();
      }
    }catch(e){
      print(e);
      return null;
    }

  }
}