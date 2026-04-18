import 'package:barber_booking_app/config/api_config.dart';
import 'package:barber_booking_app/services/auth_services/auth_http_headers.dart';
import 'package:http/http.dart' as http;

class DeleteSubscriptionService {
  Future<bool?> deleteSubscription(String? id) async {
    if (id == null || id.isEmpty) return false;
    try {
      final headers = await AuthHttpHeaders.bearerJson();
      if (headers == null) return false;

      final url = Uri.parse(
        '$kApiBaseUrl/api/MasterSubscriptions/Delete-MasterSubscription/$id',
      );
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
