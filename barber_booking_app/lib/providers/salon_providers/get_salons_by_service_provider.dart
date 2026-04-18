import 'package:barber_booking_app/models/base/base_provider.dart';
import 'package:barber_booking_app/models/params/page_params.dart';
import 'package:barber_booking_app/models/salon_models/response/get_salons_response.dart';
import 'package:barber_booking_app/services/salon_services/get_salons_by_service_service.dart';

class GetSalonsByServiceProvider extends BaseProvider {
  final GetSalonsByServiceService _salonService = GetSalonsByServiceService();
  List<GetSalonsResponse>? _getSalonsResponse;

  List<GetSalonsResponse>? get getSalonsResponse => _getSalonsResponse;
  Future<bool> getSalons(String? serviceName, PageParams params) async {
    final trimmed = serviceName?.trim();
    if (trimmed == null || trimmed.isEmpty) {
      setError('Не указано название услуги');
      return false;
    }
    _getSalonsResponse = null;
    startLoading();
    try {
      final request = PageParams(
        Page: params.Page,
        PageSize: params.PageSize,
      );
      final response =
          await _salonService.getSalonsByServiceName(trimmed, request);
      if (response != null && response.isNotEmpty) {
        _getSalonsResponse = response;
        finishLoading();
        notifyListeners();
        return true;
      } else {
        _getSalonsResponse = [];
        finishLoading();
        notifyListeners();
        return false;
      }
    } catch (e) {
      handleError(e);
      finishLoading();
      notifyListeners();
      return false;
    }
  }
}
