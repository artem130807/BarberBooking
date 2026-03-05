import 'package:barber_booking_app/models/base/base_provider.dart';
import 'package:barber_booking_app/models/master_models/response/get_masters_response.dart';
import 'package:barber_booking_app/services/master_services/get_masters_service.dart';

class GetMastersProvider extends BaseProvider {
  final GetMastersService _mastersService = GetMastersService();
  List<GetMastersResponse>? _masters;

  List<GetMastersResponse>? get masters => _masters;

  Future<bool> loadMasters(String salonId) async {
    startLoading();
    try {
      final response = await _mastersService.getMasters(salonId);
      if (response != null && response.isNotEmpty) {
        _masters = response;
        finishLoading();
        notifyListeners();
        return true;
      } else {
        _masters = [];
        setError('В этом салоне пока нет мастеров');
        finishLoading();
        return false;
      }
    } catch (e) {
      setError(e.toString());
      finishLoading();
      return false;
    }
  }
}