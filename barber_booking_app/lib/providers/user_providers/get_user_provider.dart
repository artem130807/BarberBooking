import 'package:barber_booking_app/models/base/base_provider.dart';
import 'package:barber_booking_app/models/user_models/responses/get_user_response.dart';
import 'package:barber_booking_app/services/user_services/get_user_service.dart';

class GetUserProvider extends BaseProvider {
  final GetUserService _getUserService = GetUserService();
  GetUserResponse? _userResponse;
  GetUserResponse? get userResponse => _userResponse;

  Future<bool?> getUser() async {
    startLoading();
    try {
      final response = await _getUserService.getUser();
    if(response != null){
      _userResponse = response;
      finishLoading();
      notifyListeners();
      return true;
    }else{
      print("Пользователь не найден");
      finishLoading();
      return false;
    }
    }catch(e){
      print(e);
      finishLoading();
      return false;
    }
  }
}