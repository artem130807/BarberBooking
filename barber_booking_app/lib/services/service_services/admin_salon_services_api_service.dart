import 'dart:convert';
import 'package:barber_booking_app/models/params/page_params.dart';
import 'package:barber_booking_app/models/service_models/request/create_service_request.dart';
import 'package:barber_booking_app/models/service_models/request/update_service_request.dart';
import 'package:barber_booking_app/models/service_models/response/service_admin_list_item.dart';
import 'package:http/http.dart' as http;
import 'package:barber_booking_app/config/api_config.dart';

class AdminSalonServicesApiService {

  Map<String, String> _headers(String? token) => {
        'Content-Type': 'application/json',
        if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
      };

  Future<Map<String, dynamic>?> getPaged(
    String salonId,
    PageParams pageParams,
    String? token,
  ) async {
    try {
      final qp = <String, String>{
        'Page': '${pageParams.Page ?? 1}',
        'PageSize': '${pageParams.PageSize ?? 30}',
      };
      final url = Uri.parse(
        '$kApiBaseUrl/api/Services/get-services-by-salon-paged/$salonId',
      ).replace(queryParameters: qp);
      final response = await http.get(url, headers: _headers(token));
      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      }
      if (response.statusCode == 400) {
        final b = response.body.toLowerCase();
        if (b.contains('пуст') || b.contains('empty')) {
          return {'data': <dynamic>[], 'count': 0};
        }
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<Map<String, dynamic>?> getTopServicesPaged(
    String salonId,
    PageParams pageParams,
    String? token,
  ) async {
    try {
      final qp = <String, String>{
        'Page': '${pageParams.Page ?? 1}',
        'PageSize': '${pageParams.PageSize ?? 30}',
      };
      final url = Uri.parse(
        '$kApiBaseUrl/api/Services/get-top-services-by-salon/$salonId',
      ).replace(queryParameters: qp);
      final response = await http.get(url, headers: _headers(token));
      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      }
      if (response.statusCode == 400) {
        return {'data': <dynamic>[], 'count': 0};
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  List<ServiceAdminListItem>? parseList(Map<String, dynamic> json) {
    final raw = json['data'];
    if (raw is! List) return null;
    return raw
        .map((e) => ServiceAdminListItem.fromJson(
              Map<String, dynamic>.from(e as Map),
            ))
        .toList();
  }

  int parseCount(Map<String, dynamic> json) {
    final c = json['count'];
    if (c is int) return c;
    if (c is num) return c.toInt();
    return 0;
  }

  Future<bool> create(CreateServiceRequest body, String? token) async {
    try {
      final url = Uri.parse('$kApiBaseUrl/api/Services/create-service');
      final response = await http.post(
        url,
        headers: _headers(token),
        body: json.encode(body.toJson()),
      );
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  Future<bool> update(
    String serviceId,
    UpdateServiceRequest body,
    String? token,
  ) async {
    try {
      final url = Uri.parse('$kApiBaseUrl/api/Services/update-service$serviceId');
      final response = await http.patch(
        url,
        headers: _headers(token),
        body: json.encode(body.toJson()),
      );
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  Future<bool> delete(String serviceId, String? token) async {
    try {
      final url = Uri.parse('$kApiBaseUrl/api/Services/delete-service$serviceId');
      final response = await http.delete(url, headers: _headers(token));
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}
