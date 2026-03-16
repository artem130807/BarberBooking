import 'package:http/http.dart' as http;
class DeleteReviewUserService {
  final String baseUrl = 'http://192.168.0.100:5088';
  Future<bool> deleteReview(String? id) async {
    try{
      final url = Uri.parse('$baseUrl/api/Review/Delete-Review/$id');
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
      return false;
    }
  }
}