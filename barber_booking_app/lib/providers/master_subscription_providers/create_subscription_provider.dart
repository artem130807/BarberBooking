import 'package:barber_booking_app/models/base/base_provider.dart';
import 'package:barber_booking_app/models/master_subscription_models/request/create_subscription_request.dart';
import 'package:barber_booking_app/services/master_subscription_service/create_subscription_service.dart';

class CreateSubscriptionProvider extends BaseProvider{
  final CreateSubscriptionService _createSubscriptionService = CreateSubscriptionService();
  String? _id;
  String? get id => _id;
  Future<bool> createSubscription(CreateSubscriptionRequest request, String? token) async{
    startLoading();
    try{
      var response = await _createSubscriptionService.createSubscription(request, token);
      if(response != null){
        finishLoading();  
        _id = response;
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