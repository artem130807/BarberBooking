import 'package:barber_booking_app/models/base/base_provider.dart';
import 'package:barber_booking_app/services/user_services/get_user_cities_service.dart';

class GetUserCitiesProvider extends BaseProvider {
  final GetUserCitiesService _service = GetUserCitiesService();
  List<String> _cities = [];
  List<String> get cities => List.unmodifiable(_cities);

  Future<bool> loadCities({String? search}) async {
    startLoading();
    clearError();
    try {
      final list = await _service.getCities(search: search);
      _cities = list;
      finishLoading();
      notifyListeners();
      return true;
    } catch (e) {
      setError(e.toString());
      finishLoading();
      return false;
    }
  }
}
