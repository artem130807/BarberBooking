import 'dart:ffi';
import 'package:barber_booking_app/models/base/base_provider.dart';
import 'package:barber_booking_app/models/service_models/response/get_service_search_response.dart';
import 'package:barber_booking_app/services/service_services/get_service_search_service.dart';

class GetServiceSearchProvider extends BaseProvider {
final GetServiceSearchService _getServiceSearchService = GetServiceSearchService();
List<GetServiceSearchResponse>? _list;
List<GetServiceSearchResponse>? get list => _list;

Future<bool?> getServices(String? token) async{
  startLoading();
  try{
     final response = await _getServiceSearchService.getServices(token);
      if(response != null && response.isNotEmpty){
       _list = response;
      finishLoading();  
      notifyListeners();
      return true;
      }else{
        _list = [];
        finishLoading();
        return false;
      }
  }catch(e)
  {
    print(e);
    finishLoading();
    return false;
  }
}
void clearList() {
  _list = null;
  notifyListeners();
}
}