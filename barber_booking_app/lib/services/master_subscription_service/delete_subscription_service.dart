import 'package:http/http.dart' as http;
class DeleteSubscriptionService {
  final String baseUrl = 'http://192.168.0.100:5088';
  Future<bool?> deleteSubscription(String? id) async{
    try{
     final url = Uri.parse('$baseUrl/api/MasterSubscriptions/Delete-MasterSubscription/$id');
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