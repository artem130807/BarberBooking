import 'package:barber_booking_app/models/base/base_provider.dart';
import 'package:barber_booking_app/models/params/page_params.dart';
import 'package:barber_booking_app/models/params/review_params/review_sort_params.dart';
import 'package:barber_booking_app/models/review_models/response/get_reviews_salon_response.dart';
import 'package:barber_booking_app/services/review_services/get_reviews_salon_service.dart';

class GetReviewsSalonProvider extends BaseProvider {
  final GetReviewsSalonService _getReviewsSalonService = GetReviewsSalonService();
  List<GetReviewsSalonResponse>? _reviewsList;

  List<GetReviewsSalonResponse>? get reviewsList  => _reviewsList;
  Future<bool?> getReviewsSalon(String? salonId, PageParams pageParams, ReviewSortParams sort) async{
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
  final response = await _getReviewsSalonService.getReviewsSalon(salonId, requestPage, requestSort);
  if(response != null && response.isNotEmpty){
    _reviewsList = response;
    finishLoading();  
    notifyListeners();
    return true;
  }else{
    _reviewsList = [];
    finishLoading();
    return false;
  }
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