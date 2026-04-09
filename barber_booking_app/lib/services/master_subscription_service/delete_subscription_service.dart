import 'package:http/http.dart' as http;
import 'package:barber_booking_app/config/api_config.dart';

class DeleteSubscriptionService {
  Future<bool?> deleteSubscription(String? id, String? token) async {
    if (id == null || id.isEmpty) return false;
    try {
      final url = Uri.parse(
        '$kApiBaseUrl/api/MasterSubscriptions/Delete-MasterSubscription/$id',
      );
      final headers = <String, String>{
        'Content-Type': 'application/json',
      };
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
      final response = await http.delete(url, headers: headers);
      if (response.statusCode == 200) {
        return true;
      }
      return false;
    } catch (_) {
      return null;
    }
  }
}
