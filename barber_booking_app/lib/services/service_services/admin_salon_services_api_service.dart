import 'dart:convert';

import 'package:barber_booking_app/config/api_config.dart';
import 'package:barber_booking_app/models/params/page_params.dart';
import 'package:barber_booking_app/models/service_models/request/create_service_request.dart';
import 'package:barber_booking_app/models/service_models/request/update_service_request.dart';
import 'package:barber_booking_app/models/service_models/response/service_admin_list_item.dart';
import 'package:barber_booking_app/services/auth_services/auth_http_headers.dart';
import 'package:http/http.dart' as http;

class AdminSalonServicesApiService {
  Future<Map<String, String>?> _headers() => AuthHttpHeaders.bearerJson();

  Future<Map<String, dynamic>?> getPaged(
    String salonId,
    PageParams pageParams,
  ) async {
    try {
      final h = await _headers();
      if (h == null) return null;
      final qp = <String, String>{
        'Page': '${pageParams.Page ?? 1}',
        'PageSize': '${pageParams.PageSize ?? 30}',
      };
      final url = Uri.parse(
        '$kApiBaseUrl/api/Services/get-services-by-salon-paged/$salonId',
      ).replace(queryParameters: qp);
      final response = await http.get(url, headers: h);
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
  ) async {
    try {
      final h = await _headers();
      if (h == null) return null;
      final qp = <String, String>{
        'Page': '${pageParams.Page ?? 1}',
        'PageSize': '${pageParams.PageSize ?? 30}',
      };
      final url = Uri.parse(
        '$kApiBaseUrl/api/Services/get-top-services-by-salon/$salonId',
      ).replace(queryParameters: qp);
      final response = await http.get(url, headers: h);
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

  Future<bool> create(CreateServiceRequest body) async {
    try {
      final h = await _headers();
      if (h == null) return false;
      final url = Uri.parse('$kApiBaseUrl/api/Services/create-service');
      final response = await http.post(
        url,
        headers: h,
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
  ) async {
    try {
      final h = await _headers();
      if (h == null) return false;
      final url = Uri.parse('$kApiBaseUrl/api/Services/update-service$serviceId');
      final response = await http.patch(
        url,
        headers: h,
        body: json.encode(body.toJson()),
      );
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  Future<bool> delete(String serviceId) async {
    try {
      final h = await _headers();
      if (h == null) return false;
      final url = Uri.parse('$kApiBaseUrl/api/Services/delete-service$serviceId');
      final response = await http.delete(url, headers: h);
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}
