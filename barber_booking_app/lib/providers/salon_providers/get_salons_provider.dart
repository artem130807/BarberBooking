import 'package:barber_booking_app/models/base/base_provider.dart';
import 'package:barber_booking_app/models/params/page_params.dart';
import 'package:barber_booking_app/models/params/salon_params/salon_filter.dart';
import 'package:barber_booking_app/models/salon_models/response/get_salons_response.dart';
import 'package:barber_booking_app/services/salon_services/get_salons_service.dart';

class GetSalonsProvider extends BaseProvider {
  final GetSalonsService _salonService = GetSalonsService();
  List<GetSalonsResponse>? _getSalonsResponse;

  List<GetSalonsResponse>? get getSalonsResponse => _getSalonsResponse;
  Future<bool> getSalons(PageParams params, SalonFilter filter, String? token) async{
  startLoading();
  try{
  final response = await _salonService.getSalons(params, filter, token);
  if(response != null && response.isNotEmpty){
    _getSalonsResponse = response;
    finishLoading();  
    notifyListeners();
    return true;
  }else{
    _getSalonsResponse = [];
    finishLoading();
    return false;
  }
  } catch (e) {
    handleError(e);
    return false;
  }
  }
}