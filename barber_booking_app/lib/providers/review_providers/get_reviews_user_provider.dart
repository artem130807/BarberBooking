import 'package:barber_booking_app/models/base/base_provider.dart';
import 'package:barber_booking_app/models/review_models/response/get_reviews_user_response.dart';
import 'package:barber_booking_app/services/review_services/get_reviews_user_service.dart';

class GetReviewsUserProvider extends BaseProvider {
final GetReviewsUserService _getReviewsUserService = GetReviewsUserService();
List<GetReviewsUserResponse>? _list;
List<GetReviewsUserResponse>? get list => _list;
}