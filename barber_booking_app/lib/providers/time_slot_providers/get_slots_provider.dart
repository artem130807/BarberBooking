import 'package:barber_booking_app/models/base/base_provider.dart';
import 'package:barber_booking_app/models/time_slot_models/request/get_slots_request.dart';
import 'package:barber_booking_app/models/time_slot_models/response/get_available_slots.dart';
import 'package:barber_booking_app/services/time_slot_services/get_slots_service.dart';

class GetSlotsProvider extends BaseProvider{
  final GetSlotsService  _getSlotsService = GetSlotsService();
  List<GetAvailableSlots>? _list;

  List<GetAvailableSlots>? get list => _list;
  Future<bool?> getAvailableSlots(String? masterId, GetSlotsRequest request) async{
    startLoading();
    try{
      final response = await _getSlotsService.getSlots(masterId, request);
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
  void clearList() {
  _list = null;
  notifyListeners();
}
}