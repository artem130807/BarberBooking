import 'dart:convert';
import 'package:barber_booking_app/models/master_models/request/create_master_profile_admin_request.dart';
import 'package:barber_booking_app/models/master_models/response/master_profile_info_admin_response.dart';
import 'package:barber_booking_app/models/params/page_params.dart';
import 'package:http/http.dart' as http;

class AdminSalonMastersApiService {
  final String baseUrl = 'http://192.168.0.100:5088';

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
        '$baseUrl/api/MasterProfile/GetMastersBySalonPaged/$salonId',
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

  List<MasterProfileInfoAdminResponse>? parseList(Map<String, dynamic> json) {
    final raw = json['data'];
    if (raw is! List) return null;
    return raw
        .map((e) => MasterProfileInfoAdminResponse.fromJson(
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

  Future<String?> createErrorMessage(
    CreateMasterProfileAdminRequest body,
    String? token,
  ) async {
    try {
      final url = Uri.parse('$baseUrl/api/MasterProfile/CreateMasterProfile');
      final response = await http.post(
        url,
        headers: _headers(token),
        body: json.encode(body.toJson()),
      );
      if (response.statusCode == 200) return null;
      try {
        final err = json.decode(response.body);
        if (err is Map && err['error'] != null) {
          return err['error'].toString();
        }
      } catch (_) {}
      return 'Не удалось создать профиль мастера';
    } catch (_) {
      return 'Ошибка сети';
    }
  }

  Future<String?> deleteMaster(String masterProfileId, String? token) async {
    try {
      final url = Uri.parse(
        '$baseUrl/api/MasterProfile/DeleteMasterProfile$masterProfileId',
      );
      final response = await http.delete(url, headers: _headers(token));
      if (response.statusCode == 200) return null;
      try {
        final err = json.decode(response.body);
        if (err is Map && err['error'] != null) {
          return err['error'].toString();
        }
      } catch (_) {}
      return 'Не удалось удалить мастера';
    } catch (_) {
      return 'Ошибка сети';
    }
  }
}
