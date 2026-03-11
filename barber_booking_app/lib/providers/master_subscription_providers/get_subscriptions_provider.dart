import 'package:barber_booking_app/models/base/base_provider.dart';
import 'package:barber_booking_app/models/master_subscription_models/response/get_subscriptions_response.dart';
import 'package:barber_booking_app/services/master_subscription_service/get_subscriptions_service.dart';

class GetSubscriptionsProvider extends BaseProvider{
final GetSubscriptionsService _getSubscriptionsService = GetSubscriptionsService();
List<GetSubscriptionsResponse>? _list;
List<GetSubscriptionsResponse>? get list => _list;

Future<bool?> getSubscriptions(String? token) async{
startLoading();
try{
  startLoading();
    try{
      final response = await _getSubscriptionsService.getSubscriptions(token);
      if(response != null && response.isNotEmpty){
       _list = response;
      finishLoading();  
      notifyListeners();
      return true;
      }else{
        _list = [];
        finishLoading();
        return false;
      }
    }catch(e){
      print(e);
      finishLoading();
      return false;
    }
}catch(e){
  print(e);
  finishLoading();
  return false;
}
}
void clearList() {
  _list = null;
  notifyListeners();
}
}