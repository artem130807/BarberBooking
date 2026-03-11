import 'package:barber_booking_app/models/master_models/response/get_masterProfile_subscription_Info_response.dart';

class GetSubscriptionsResponse {

String? id;
GetMasterprofileSubscriptionInfoResponse? masterNavigation;

GetSubscriptionsResponse({this.id, this.masterNavigation});

 factory GetSubscriptionsResponse.fromJson(Map<String, dynamic> json){
    return GetSubscriptionsResponse(
      id: json['id'],
      masterNavigation: json['masterProfileNavigation'] != null ?GetMasterprofileSubscriptionInfoResponse.fromJson(json['masterProfileNavigation']): null,
    );
  }
}