import 'dart:convert';

import 'package:barber_booking_app/config/api_config.dart';
import 'package:barber_booking_app/models/params/page_params.dart';
import 'package:barber_booking_app/models/params/review_params/review_sort_params.dart';
import 'package:barber_booking_app/models/review_models/response/get_reviews_master_response.dart';
import 'package:barber_booking_app/models/review_models/response/master_reviews_page_result.dart';
import 'package:http/http.dart' as http;

class GetReviewsMasterService {
  Future<List<GetReviewsMasterResponse>?> getReviewsMaster(
    String? masterId,
    PageParams pageParams,
    ReviewSortParams sort,
  ) async {
    final page = await fetchMasterReviewsPage(masterId, pageParams, sort);
    return page?.items;
  }

  Future<MasterReviewsPageResult?> fetchMasterReviewsPage(
    String? masterId,
    PageParams pageParams,
    ReviewSortParams sort,
  ) async {
    if (masterId == null || masterId.isEmpty) return null;
    try {
      final qp = <String, String>{
        'Page': '${pageParams.Page ?? 1}',
        'PageSize': '${pageParams.PageSize ?? 20}',
      };
      if (sort.OrderBy != null) {
        qp['OrderBy'] = sort.OrderBy.toString();
      }
      if (sort.OrderbyDescending != null) {
        qp['OrderbyDescending'] = sort.OrderbyDescending.toString();
      }
      final url = Uri.parse(
        '$kApiBaseUrl/api/Review/GetReviewsByMasterIdSort/$masterId',
      ).replace(queryParameters: qp);
      final response = await http.get(
        url,
        headers: const {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        if (decoded is! Map<String, dynamic>) return null;
        final rawList = decoded['data'] ?? decoded['Data'];
        final countRaw = decoded['count'] ?? decoded['Count'];
        final totalCount = countRaw is int
            ? countRaw
            : int.tryParse(countRaw?.toString() ?? '') ?? 0;
        if (rawList is! List) {
          return MasterReviewsPageResult(items: [], totalCount: totalCount);
        }
        final items = rawList
            .map((e) => GetReviewsMasterResponse.fromJson(
                  Map<String, dynamic>.from(e as Map),
                ))
            .toList();
        return MasterReviewsPageResult(items: items, totalCount: totalCount);
      }
      if (response.statusCode == 400) {
        return MasterReviewsPageResult(items: [], totalCount: 0);
      }
      return null;
    } catch (_) {
      return null;
    }
  }
}
