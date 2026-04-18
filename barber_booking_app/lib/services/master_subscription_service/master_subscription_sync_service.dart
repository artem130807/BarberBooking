import 'package:barber_booking_app/models/master_subscription_models/request/create_subscription_request.dart';
import 'package:barber_booking_app/models/master_subscription_models/response/get_subscriptions_response.dart';
import 'package:barber_booking_app/services/master_subscription_service/create_subscription_service.dart';
import 'package:barber_booking_app/services/master_subscription_service/delete_subscription_service.dart';
import 'package:barber_booking_app/services/master_subscription_service/get_subscriptions_service.dart';

class MasterSubscriptionSyncService {
  final CreateSubscriptionService _create = CreateSubscriptionService();
  final DeleteSubscriptionService _delete = DeleteSubscriptionService();
  final GetSubscriptionsService _list = GetSubscriptionsService();

  Future<bool> persistIfChanged({
    required bool initialSubscribed,
    required bool draftSubscribed,
    required String masterId,
  }) async {
    if (draftSubscribed == initialSubscribed) return true;

    if (draftSubscribed) {
      final req = CreateSubscriptionRequest(MasterId: masterId);
      final id = await _create.createSubscription(req);
      return id != null;
    }

    final subscriptionId = await _findSubscriptionIdForMaster(masterId);
    if (subscriptionId == null) return false;
    final ok = await _delete.deleteSubscription(subscriptionId);
    return ok == true;
  }

  Future<String?> _findSubscriptionIdForMaster(String masterId) async {
    final List<GetSubscriptionsResponse>? items = await _list.getSubscriptions();
    if (items == null) return null;
    for (final item in items) {
      final mid = item.masterNavigation?.Id;
      if (mid != null && mid == masterId) {
        return item.id;
      }
    }
    return null;
  }
}
