import 'package:barber_booking_app/models/base/base_provider.dart';
import 'package:barber_booking_app/models/service_models/response/get_services_response.dart';
import 'package:barber_booking_app/services/service_services/get_services_service.dart';

class GetServicesProvider extends BaseProvider {
  final GetServicesService  _getServicesService = GetServicesService();
  List< GetServicesResponse>? _list;

  List<GetServicesResponse>? get list => _list;
  Future<bool?> getServices(String? salonId) async{
    startLoading();
    try{
      final response = await _getServicesService.getServices(salonId);
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
    }catch(e){
      print(e);
      setError(e.toString());
      finishLoading();
      return false;
    }
  }

  Future<bool?> getServicesForMasterBooking(String? masterProfileId) async {
    startLoading();
    try {
      final response =
          await _getServicesService.getServicesForMasterBooking(masterProfileId);
      if (response != null) {
        _list = response;
        finishLoading();
        notifyListeners();
        return response.isNotEmpty;
      }
      _list = [];
      setError('Не удалось загрузить услуги');
      finishLoading();
      notifyListeners();
      return false;
    } catch (e) {
      setError(e.toString());
      finishLoading();
      return false;
    }
  }
  void clearList() {
  _list = null;
  notifyListeners();
}
}