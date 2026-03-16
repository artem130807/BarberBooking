import 'package:barber_booking_app/models/base/base_provider.dart';
import 'package:barber_booking_app/providers/auth_providers/auth_provider.dart';
import 'package:barber_booking_app/services/user_services/update_user_city_service.dart';

class UpdateUserCityProvider extends BaseProvider {
  final UpdateUserCityService _service = UpdateUserCityService();

  /// [authProvider] — для сохранения нового токена после смены города (салоны будут по новому городу).
  Future<String?> updateCity(String? token, String city, [AuthProvider? authProvider]) async {
    if (token == null || token.isEmpty) {
      setError('Необходима авторизация');
      return null;
    }
    if (city.trim().isEmpty) {
      setError('Укажите город');
      return null;
    }
    startLoading();
    clearError();
    try {
      final result = await _service.updateCity(token, city);
      finishLoading();
      if (result != null) {
        if (result.token != null && result.token!.isNotEmpty && authProvider != null) {
          authProvider.updateToken(result.token!);
        }
        notifyListeners();
        return result.city;
      }
      return null;
    } catch (e) {
      finishLoading();
      return null;
    }
  }
}
