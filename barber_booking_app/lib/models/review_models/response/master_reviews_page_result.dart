import 'package:barber_booking_app/models/review_models/response/get_reviews_master_response.dart';

class MasterReviewsPageResult {
  MasterReviewsPageResult({
    required this.items,
    required this.totalCount,
  });

  final List<GetReviewsMasterResponse> items;
  final int totalCount;
}
