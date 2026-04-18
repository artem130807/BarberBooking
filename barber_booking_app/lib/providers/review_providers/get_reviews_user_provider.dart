import 'package:barber_booking_app/models/base/base_provider.dart';
import 'package:barber_booking_app/models/params/page_params.dart';
import 'package:barber_booking_app/models/review_models/response/get_reviews_user_response.dart';
import 'package:barber_booking_app/services/review_services/get_reviews_user_service.dart';

class GetReviewsUserProvider extends BaseProvider {
  final GetReviewsUserService _getReviewsUserService = GetReviewsUserService();
  List<GetReviewsUserResponse>? _list;
  List<GetReviewsUserResponse>? get list => _list;

  Future<bool?> getReviews(PageParams pageParams) async {
    startLoading();
    try {
      final response =
          await _getReviewsUserService.getReviews(pageParams);
      if (response != null && response.isNotEmpty) {
        _list = response;
        finishLoading();
        notifyListeners();
        return true;
      } else {
        _list = [];
        finishLoading();
        return false;
      }
    } catch (e) {
      print(e);
      finishLoading();
      return false;
    }
  }
}
