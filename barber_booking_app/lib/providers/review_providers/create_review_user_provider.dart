import 'package:barber_booking_app/models/base/base_provider.dart';
import 'package:barber_booking_app/models/review_models/request/create_review_request.dart';
import 'package:barber_booking_app/services/review_services/create_review_user_service.dart';

class CreateReviewUserProvider extends BaseProvider {
  final CreateReviewUserService _createReviewUserService = CreateReviewUserService();
  Future<bool> createReview(CreateReviewRequest request, String? token) async{
    startLoading();
    try {
      final response = await _createReviewUserService.createReview(request, token);
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