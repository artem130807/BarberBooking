import 'package:barber_booking_app/models/base/base_provider.dart';
import 'package:barber_booking_app/models/params/page_params.dart';
import 'package:barber_booking_app/models/params/review_params/review_sort_params.dart';
import 'package:barber_booking_app/models/review_models/response/get_reviews_master_response.dart';
import 'package:barber_booking_app/services/review_services/get_reviews_master_service.dart';

class GetReviewsMasterProvider extends BaseProvider {
  final GetReviewsMasterService _getReviewsMasterService = GetReviewsMasterService();
  List<GetReviewsMasterResponse>? _reviewsList;

  List<GetReviewsMasterResponse>? get reviewsList  => _reviewsList;
  Future<bool?> getReviewsMaster(String? masterId, PageParams pageParams, ReviewSortParams sort) async{
  startLoading();
  try{
    final requestPage = PageParams(
    Page: pageParams.Page,
    PageSize: pageParams.PageSize
  );
    final requestSort = ReviewSortParams(
    OrderBy: sort.OrderBy,
    OrderbyDescending: sort.OrderbyDescending
  );
    final response = await _getReviewsMasterService.getReviewsMaster(masterId, requestPage, requestSort);
    if (response != null) {
      _reviewsList = response;
      finishLoading();
      notifyListeners();
      return true;
    }
    _reviewsList = [];
    finishLoading();
    return false;
  }catch(e){
    print(e);
    setError(e.toString());
    finishLoading();
    return false;
  }
  }
  void clearList() {
  _reviewsList = null;
  notifyListeners();
}
}