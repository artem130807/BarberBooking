import 'package:http/http.dart' as http;
import 'package:barber_booking_app/config/api_config.dart';
class DeleteAppointmentService {

  Future<bool?> deleteAppointment(String? id) async{
    try{
      final url = Uri.parse('$kApiBaseUrl/api/Appointment/delete-appointment/$id');
      final response = await http.delete(url, headers: {'Content-Type': 'application/json'},);
      print('📥 Статус: ${response.statusCode}');
      print('📥 Ответ: ${response.body}');
      if (response.statusCode == 200) {
        print('📊 Успешное удаление');
        return true;
      }else{
        print("Ошибка при удалении");
        return false;
      }
    }catch(e){
      print(e);
    }
  }
}
