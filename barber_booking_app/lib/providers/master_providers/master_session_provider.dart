import 'package:barber_booking_app/models/base/base_provider.dart';
import 'package:barber_booking_app/models/master_models/response/get_master_response.dart';
import 'package:barber_booking_app/services/master_services/master_current_profile_service.dart';

class MasterSessionProvider extends BaseProvider {
  MasterSessionProvider() : _service = MasterCurrentProfileService();

  final MasterCurrentProfileService _service;

  GetMasterResponse? _profile;

  GetMasterResponse? get profile => _profile;

  String? get masterId => _profile?.Id;

  Future<void> load() async {
    startLoading();
    clearError();
    try {
      final r = await _service.fetch();
      if (r == null) {
        setError('Не удалось загрузить профиль мастера');
        _profile = null;
      } else {
        _profile = r;
        clearError();
      }
      finishLoading();
    } catch (e) {
      handleError(e);
      _profile = null;
    }
    notifyListeners();
  }

  void clear() {
    _profile = null;
    resetState();
    notifyListeners();
  }
}
