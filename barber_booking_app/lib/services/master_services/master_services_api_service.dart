import 'dart:convert';

import 'package:barber_booking_app/config/api_config.dart';
import 'package:barber_booking_app/models/master_interface_models/request/create_master_service_request.dart';
import 'package:barber_booking_app/models/master_interface_models/response/master_service_link_response.dart';
import 'package:barber_booking_app/models/master_interface_models/response/salon_service_catalog_item.dart';
import 'package:barber_booking_app/services/auth_services/auth_http_headers.dart';
import 'package:http/http.dart' as http;

class MasterServicesApiService {
  String? _errorFromResponse(http.Response r) {
    if (r.statusCode >= 200 && r.statusCode < 300) return null;
    final raw = r.body;
    if (raw.isEmpty) return 'Ошибка ${r.statusCode}';
    try {
      final j = json.decode(raw);
      if (j is Map && j['error'] != null) return j['error'].toString();
      if (j is String) return j;
    } catch (_) {}
    return raw.length > 220 ? 'Ошибка ${r.statusCode}' : raw;
  }

  Future<List<MasterServiceLinkResponse>?> fetchMasterServices({
    required String masterProfileId,
  }) async {
    final headers = await AuthHttpHeaders.bearerJson();
    if (headers == null || masterProfileId.isEmpty) return null;
    try {
      final url = Uri.parse(
        '$kApiBaseUrl/api/MasterServices/get-masterService-by-master/$masterProfileId',
      );
      final response = await http.get(url, headers: headers);
      if (response.statusCode != 200) return null;
      final decoded = json.decode(response.body);
      if (decoded is! List) return null;
      return decoded
          .map((e) => MasterServiceLinkResponse.fromJson(
                Map<String, dynamic>.from(e as Map),
              ))
          .toList();
    } catch (_) {
      return null;
    }
  }

  Future<(List<SalonServiceCatalogItem>? items, String? error)>
      fetchSalonServicesForMaster() async {
    final headers = await AuthHttpHeaders.bearerJson();
    if (headers == null) {
      return (null, 'Нужна авторизация');
    }
    try {
      final url = Uri.parse(
        '$kApiBaseUrl/api/Services/get-services-salon-for-Master',
      );
      final response = await http.get(url, headers: headers);
      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        if (decoded is! List) return (<SalonServiceCatalogItem>[], null);
        final list = decoded
            .map((e) => SalonServiceCatalogItem.fromJson(
                  Map<String, dynamic>.from(e as Map),
                ))
            .where((e) => e.id.isNotEmpty)
            .toList();
        return (list, null);
      }
      return (null, _errorFromResponse(response) ?? 'Не удалось загрузить каталог');
    } catch (_) {
      return (null, 'Ошибка сети');
    }
  }

  Future<String?> addService({
    required String serviceId,
  }) async {
    final headers = await AuthHttpHeaders.bearerJson();
    if (headers == null) return 'Нужна авторизация';
    try {
      final url = Uri.parse('$kApiBaseUrl/api/MasterServices/create-masterService');
      final response = await http.post(
        url,
        headers: headers,
        body: json.encode(
            CreateMasterServiceRequest(serviceId: serviceId).toJson()),
      );
      if (response.statusCode == 200) return null;
      return _errorFromResponse(response) ?? 'Не удалось добавить услугу';
    } catch (_) {
      return 'Ошибка сети';
    }
  }

  Future<String?> removeService({
    required String masterServiceLinkId,
  }) async {
    final headers = await AuthHttpHeaders.bearerJson();
    if (headers == null) return 'Нужна авторизация';
    try {
      final url = Uri.parse(
        '$kApiBaseUrl/api/MasterServices/delete-masterService/$masterServiceLinkId',
      );
      final response = await http.delete(url, headers: headers);
      if (response.statusCode == 200) return null;
      return _errorFromResponse(response) ?? 'Не удалось удалить';
    } catch (_) {
      return 'Ошибка сети';
    }
  }
}
