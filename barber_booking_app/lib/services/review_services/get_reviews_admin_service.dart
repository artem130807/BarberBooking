import 'dart:convert';

import 'package:barber_booking_app/config/api_config.dart';
import 'package:barber_booking_app/models/params/page_params.dart';
import 'package:barber_booking_app/models/params/review_params/review_admin_filter.dart';
import 'package:barber_booking_app/models/review_models/response/review_admin_list_item.dart';
import 'package:barber_booking_app/services/auth_services/auth_http_headers.dart';
import 'package:http/http.dart' as http;

class GetReviewsAdminService {
  Future<Map<String, dynamic>?> getAll({
    required PageParams pageParams,
    required ReviewAdminFilter filter,
  }) async {
    try {
      final headers = await AuthHttpHeaders.bearerJson();
      if (headers == null) return null;

      final qp = <String, String>{
        'Page': '${pageParams.Page ?? 1}',
        'PageSize': '${pageParams.PageSize ?? 20}',
      };
      final sid = filter.salonId;
      if (sid != null && sid.isNotEmpty) qp['SalonId'] = sid;
      final mid = filter.masterId;
      if (mid != null && mid.isNotEmpty) qp['MasterId'] = mid;
      if (filter.from != null) {
        qp['From'] = filter.from!.toUtc().toIso8601String();
      }
      if (filter.to != null) {
        qp['To'] = filter.to!.toUtc().toIso8601String();
      }
      if (filter.prioritizeLowRatings) {
        qp['LowRating'] = 'true';
      }
      final url = Uri.parse('$kApiBaseUrl/api/Review/GetAllReviewsAdmin')
          .replace(queryParameters: qp);
      final response = await http.get(
        url,
        headers: headers,
      );
      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  List<ReviewAdminListItem>? parseData(Map<String, dynamic> json) {
    final raw = json['data'];
    if (raw is! List) return null;
    return raw
        .map((e) => ReviewAdminListItem.fromJson(
            Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  int parseCount(Map<String, dynamic> json) {
    final c = json['count'];
    if (c is int) return c;
    if (c is num) return c.toInt();
    return 0;
  }

  Future<List<ReviewAdminListItem>> fetchAllPages(
    ReviewAdminFilter filter, {
    int pageSize = 50,
  }) async {
    final all = <ReviewAdminListItem>[];
    var page = 1;
    while (true) {
      final map = await getAll(
        pageParams: PageParams(Page: page, PageSize: pageSize),
        filter: filter,
      );
      if (map == null) break;
      final chunk = parseData(map) ?? [];
      all.addAll(chunk);
      if (chunk.length < pageSize) break;
      page++;
    }
    return all;
  }
}
