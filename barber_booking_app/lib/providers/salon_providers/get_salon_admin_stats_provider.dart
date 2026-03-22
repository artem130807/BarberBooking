import 'package:barber_booking_app/models/base/base_provider.dart';
import 'package:barber_booking_app/models/salon_models/response/salon_admin_stats_response.dart';
import 'package:barber_booking_app/services/salon_services/get_salon_admin_stats_service.dart';

class GetSalonAdminStatsProvider extends BaseProvider {
  final GetSalonAdminStatsService _service = GetSalonAdminStatsService();
  SalonAdminStatsResponse? _stats;

  SalonAdminStatsResponse? get stats => _stats;

  Future<void> load(String salonId, String? token) async {
    startLoading();
    try {
      _stats = await _service.getStats(salonId, token);
      if (_stats == null) {
        setError('Не удалось загрузить данные салона');
      }
      finishLoading();
    } catch (e) {
      handleError(e);
    }
  }

  void clear() {
    _stats = null;
    resetState();
  }
}
