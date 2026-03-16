import 'package:barber_booking_app/models/base/base_provider.dart';
import 'package:barber_booking_app/services/review_services/delete_review_user_service.dart';

class DeleteReviewUserProvider extends BaseProvider {
  final DeleteReviewUserService _deleteReviewUserService = DeleteReviewUserService();

  Future<bool> deleteReview(String? id) async {
    if (id == null || id.isEmpty) return false;
    startLoading();
    try {
      final response = await _deleteReviewUserService.deleteReview(id);
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