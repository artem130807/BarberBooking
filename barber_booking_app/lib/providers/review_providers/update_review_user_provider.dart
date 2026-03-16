import 'package:barber_booking_app/models/base/base_provider.dart';
import 'package:barber_booking_app/models/review_models/request/update_review_request.dart';
import 'package:barber_booking_app/services/review_services/update_review_user_service.dart';

class UpdateReviewUserProvider extends BaseProvider {
  final UpdateReviewUserService _updateReviewUserService = UpdateReviewUserService();

  Future<bool> updateReview(String? id, UpdateReviewRequest request) async {
    if (id == null || id.isEmpty) return false;
    startLoading();
    try {
      final response = await _updateReviewUserService.updateReview(id, request);
      finishLoading();
      return response == true;
    } catch (e) {
      print(e);
      setError(e.toString());
      finishLoading();
      return false;
    }
  }
}