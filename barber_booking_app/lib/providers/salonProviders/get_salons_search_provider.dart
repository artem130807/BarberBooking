import 'package:barber_booking_app/models/Params/page_params.dart';
import 'package:barber_booking_app/models/SalonModels/response/get_salons_response.dart';
import 'package:barber_booking_app/models/base/base_provider.dart';
import 'package:barber_booking_app/services/salon_services/get_salons_search_service.dart';

class GetSalonsSearchProvider extends BaseProvider{
 final GetSalonsSearchService _getSalonsSearchService = GetSalonsSearchService();
 List<GetSalonsResponse>? _getSalonsResponse;
 String? _lastSearchQuery;
 List<GetSalonsResponse>? get getSalonsResponse => _getSalonsResponse;
 String? get lastSearchQuery => _lastSearchQuery;
 Future<bool> getSalons(String? name ,PageParams params, String? token) async{
  startLoading();
  _lastSearchQuery = name;
  try{
  final request = PageParams(
    Page: params.Page,
    PageSize: params.PageSize
  );
  final response = await _getSalonsSearchService.GetSalons(name, request, token);
  if(response != null && response.isNotEmpty){
    _getSalonsResponse = response;
    finishLoading();  
    notifyListeners();
    return true;
  }else{
    _getSalonsResponse = [];
    setError('Список салонов в вашем городе пуст');  
    finishLoading();
    return false;
  }
  }catch(e){
    print(e);
    setError(e.toString());
    return false;
  }
  }
  void clearResults() {
    _getSalonsResponse = null;
    _lastSearchQuery = null;
    resetState();
  }
}