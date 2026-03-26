import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:barber_booking_app/config/api_config.dart';

class GetUserCitiesService {

  Future<List<String>> getCities({String? search}) async {
    try {
      final queryParams = <String, String>{};
      if (search != null && search.trim().isNotEmpty) {
        queryParams['city'] = search.trim();
      }
      final url = Uri.parse('$kApiBaseUrl/api/Users/get_cities').replace(
        queryParameters: queryParams.isEmpty ? null : queryParams,
      );
      final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        if (jsonList.isEmpty) return [];
        return jsonList.map((e) => e as String).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }
}