import 'package:barber_booking_app/config/api_config.dart';
import 'package:barber_booking_app/services/auth_services/auth_http_headers.dart';
import 'package:http/http.dart' as http;

class DeleteReviewUserService {
  Future<bool> deleteReview(String? id) async {
    try {
      final headers = await AuthHttpHeaders.bearerJson();
      if (headers == null) return false;

      final url = Uri.parse('$kApiBaseUrl/api/Review/Delete-Review/$id');
      final response = await http.delete(url, headers: headers);
      print('📥 Статус: ${response.statusCode}');
      print('📥 Ответ: ${response.body}');
      if (response.statusCode == 200) {
        print('📊 Успешное удаление');
        return true;
      } else {
        print('Ошибка при удалении');
        return false;
      }
    } catch (e) {
      print(e);
      return false;
    }
  }
}
