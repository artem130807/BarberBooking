import 'package:barber_booking_app/models/base/base_provider.dart';
import 'package:barber_booking_app/services/messages_services/get_count_messages_service.dart';

class GetCountMessagesProvider extends BaseProvider {
  final GetCountMessagesService _service = GetCountMessagesService();

  int _count = 0;
  int get count => _count;

  Future<bool> loadCount(String? token) async {
    startLoading();
    try {
      _count = await _service.getCountUnreadMessages(token);
      finishLoading();
      notifyListeners();
      return true;
    } catch (_) {
      finishLoading();
      return false;
    }
  }

  void resetCount() {
    _count = 0;
    notifyListeners();
  }
}
