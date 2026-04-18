import 'package:barber_booking_app/models/base/base_provider.dart';
import 'package:barber_booking_app/services/master_subscription_service/delete_subscription_service.dart';

class DeleteSubscriptionProvider extends BaseProvider {
  final DeleteSubscriptionService _deleteSubscriptionService =
      DeleteSubscriptionService();

  Future<bool> deleteSubscription(String? id) async {
    final response = await _deleteSubscriptionService.deleteSubscription(id);
    if (response != null) return response;
    return false;
  }
}
