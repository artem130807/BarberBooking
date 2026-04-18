import 'package:barber_booking_app/models/base/base_provider.dart';
import 'package:barber_booking_app/models/master_models/response/get_master_response.dart';
import 'package:barber_booking_app/services/master_services/get_master_service.dart';

class GetMasterProvider extends BaseProvider {
  final GetMasterService _masterService = GetMasterService();
  GetMasterResponse? _getMasterResponse;

  GetMasterResponse? get getMasterResponse => _getMasterResponse;
  GetMasterService? get masterService => _masterService;

  Future<bool> getMaster(String id) async {
    startLoading();
    try {
      final response = await _masterService.getMaster(id);
      if (response != null) {
        _getMasterResponse = response;
        finishLoading();
        notifyListeners();
        return true;
      } else {
        print("Мастер не найден");
        setError("Мастер не найден");
        finishLoading();
        return false;
      }
    } catch (e) {
      finishLoading();
      setError(e.toString());
      return false;
    }
  }
}
