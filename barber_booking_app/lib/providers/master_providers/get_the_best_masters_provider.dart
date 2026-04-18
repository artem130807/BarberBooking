import 'package:barber_booking_app/models/base/base_provider.dart';
import 'package:barber_booking_app/models/master_models/response/get_the_best_masters_response.dart';
import 'package:barber_booking_app/services/master_services/get_the_best_masters_service.dart';

class GetTheBestMastersProvider extends BaseProvider {
  final GetTheBestMastersService _getTheBestMastersService = GetTheBestMastersService();
  List<GetTheBestMastersResponse>? _getMasterResponse;

  List<GetTheBestMastersResponse>? get getMasterResponse => _getMasterResponse;

  Future<bool> getMasters(int? take) async {
    startLoading();
    try {
      final response = await _getTheBestMastersService.getMasters(take);
      if(response != null && response.isNotEmpty){
          _getMasterResponse = response;
          finishLoading();  
          notifyListeners();
          return true;
      }else{
        _getMasterResponse = [];
        setError('Список мастеров пуст');  
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