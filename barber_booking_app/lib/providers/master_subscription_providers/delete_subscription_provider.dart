import 'package:barber_booking_app/models/base/base_provider.dart';
import 'package:barber_booking_app/services/master_subscription_service/delete_subscription_service.dart';

class DeleteSubscriptionProvider extends BaseProvider{
final DeleteSubscriptionService _deleteSubscriptionService = DeleteSubscriptionService();
Future<bool> deleteSubscription(String? id, String? token) async{
  startLoading();
  try{
     var response = await _deleteSubscriptionService.deleteSubscription(id, token);
      if(response == true){
        finishLoading();  
        notifyListeners();
        return true;
      }else{
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