import 'package:barber_booking_app/models/base/base_provider.dart';
import 'package:barber_booking_app/models/params/page_params.dart';
import 'package:barber_booking_app/models/review_models/response/get_reviews_master_response.dart';
import 'package:barber_booking_app/services/review_services/get_reviews_master_service.dart';

class GetReviewsMasterProvider extends BaseProvider {
  final GetReviewsMasterService _getReviewsMasterService = GetReviewsMasterService();
  List<GetReviewsMasterResponse>? _reviewsList;

  List<GetReviewsMasterResponse>? get reviewsList  => _reviewsList;
  Future<bool?> getReviewsMaster(String? masterId, PageParams pageParams) async{
  startLoading();
  try{
    final request = PageParams(
    Page: pageParams.Page,
    PageSize: pageParams.PageSize
  );
    final response = await _getReviewsMasterService.getReviewsMaster(masterId, request);
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
}