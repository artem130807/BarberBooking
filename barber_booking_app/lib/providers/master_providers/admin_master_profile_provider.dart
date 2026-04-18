import 'package:barber_booking_app/models/base/base_provider.dart';
import 'package:barber_booking_app/models/master_models/response/master_profile_info_for_admin_response.dart';
import 'package:barber_booking_app/services/master_services/get_master_profile_for_admin_service.dart';

/// Профиль мастера для админ-экранов ([GetMasterProfileForAdminService]).
class AdminMasterProfileProvider extends BaseProvider {
  final GetMasterProfileForAdminService _service =
      GetMasterProfileForAdminService();
  MasterProfileInfoForAdminResponse? _master;

  MasterProfileInfoForAdminResponse? get master => _master;

  Future<bool> load(String masterId) async {
    _master = null;
    startLoading();
    try {
      final response = await _service.getProfile(masterId);
      if (response == null) {
        setError('Не удалось загрузить профиль мастера');
        finishLoading();
        return false;
      }
      _master = response;
      finishLoading();
      return true;
    } catch (e) {
      handleError(e);
      return false;
    }
  }

  void clear() {
    _master = null;
    resetState();
  }
}
