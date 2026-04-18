import 'package:barber_booking_app/models/base/base_provider.dart';
import 'package:barber_booking_app/models/salon_models/request/update_salon_request.dart';
import 'package:barber_booking_app/models/salon_models/response/salon_admin_stats_response.dart';
import 'package:barber_booking_app/services/salon_services/admin_update_salon_service.dart';
import 'package:barber_booking_app/services/salon_services/get_salon_admin_stats_service.dart';

class GetSalonAdminStatsProvider extends BaseProvider {
  final GetSalonAdminStatsService _service = GetSalonAdminStatsService();
  final AdminUpdateSalonService _updateSalon = AdminUpdateSalonService();
  SalonAdminStatsResponse? _stats;

  SalonAdminStatsResponse? get stats => _stats;

  Future<bool> updateSalon(
    String salonId,
    UpdateSalonRequest body,
  ) async {
    try {
      final r = await _updateSalon.patch(salonId, body);
      if (!r.ok) {
        setError(r.error ?? 'Не удалось сохранить');
        return false;
      }
      clearError();
      _stats = await _service.getStats(salonId);
      if (_stats == null) {
        setError('Не удалось загрузить данные салона');
        return false;
      }
      notifyListeners();
      return true;
    } catch (e) {
      handleError(e);
      return false;
    }
  }

  Future<bool> updateMainPhotoUrl(
    String salonId,
    String mainPhotoUrl,
  ) async {
    return updateSalon(
      salonId,
      UpdateSalonRequest(mainPhotoUrl: mainPhotoUrl),
    );
  }

  Future<void> load(String salonId) async {
    startLoading();
    try {
      _stats = await _service.getStats(salonId);
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
