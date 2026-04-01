import 'package:barber_booking_app/models/base/base_provider.dart';
import 'package:barber_booking_app/models/user_models/responses/user_profile_by_id_response.dart';
import 'package:barber_booking_app/services/user_services/get_user_profile_by_id_service.dart';

class GetUserProfileByIdProvider extends BaseProvider {
  final GetUserProfileByIdService _service = GetUserProfileByIdService();
  UserProfileByIdResponse? _profile;

  UserProfileByIdResponse? get profile => _profile;

  Future<bool> load(String userId, String? token) async {
    _profile = null;
    startLoading();
    try {
      _profile = await _service.getProfile(userId, token);
      if (_profile == null) {
        setError('Не удалось загрузить профиль');
        finishLoading();
        return false;
      }
      finishLoading();
      return true;
    } catch (e) {
      handleError(e);
      return false;
    }
  }

  void clear() {
    _profile = null;
    resetState();
  }
}
