import 'package:barber_booking_app/models/base/base_provider.dart';
import 'package:barber_booking_app/models/salon_models/response/get_salon_admin_response.dart';
import 'package:barber_booking_app/models/salon_models/response/get_salons_response.dart';
import 'package:barber_booking_app/services/salon_services/get_salons_admin_service.dart';

class GetSalonsAdminProvider extends BaseProvider {
  final GetSalonsAdminService _service = GetSalonsAdminService();
  List<GetSalonAdminResponse>? _items;

  List<GetSalonAdminResponse>? get items => _items;

  List<GetSalonsResponse> get asSalonListItems =>
      (_items ?? []).map((e) => e.toGetSalonsResponse()).toList();

  Future<bool> load() async {
    startLoading();
    try {
      final response = await _service.getSalonsAdmin();
      if (response == null) {
        _items = null;
        setError('Не удалось загрузить список салонов');
        finishLoading();
        notifyListeners();
        return false;
      }
      _items = response;
      clearError();
      finishLoading();
      notifyListeners();
      return true;
    } catch (e) {
      handleError(e);
      return false;
    }
  }

  void clear() {
    _items = null;
    resetState();
  }
}
