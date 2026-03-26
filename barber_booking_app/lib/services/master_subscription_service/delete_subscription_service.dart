import 'package:http/http.dart' as http;
import 'package:barber_booking_app/config/api_config.dart';
class DeleteSubscriptionService {

  Future<bool?> deleteSubscription(String? id) async{
    try{
     final url = Uri.parse('$kApiBaseUrl/api/MasterSubscriptions/Delete-MasterSubscription/$id');
     final response = await http.delete(url);
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
      return null;
    }
  }
}