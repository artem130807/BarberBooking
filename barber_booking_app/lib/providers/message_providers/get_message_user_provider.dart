import 'package:barber_booking_app/models/base/base_provider.dart';
import 'package:barber_booking_app/models/messages_models/response/get_messages_user_response.dart';
import 'package:barber_booking_app/services/messages_services/get_message_user_service.dart';

class GetMessageUserProvider extends BaseProvider {
  final GetMessageUserService _service = GetMessageUserService();

  List<GetMessagesUserResponse> _messages = [];
  List<GetMessagesUserResponse> get messages => _messages;

  Future<bool> loadMessages(String? token) async {
    startLoading();
    try {
      final response = await _service.getMessages(token);
      _messages = response ?? [];
      finishLoading();
      notifyListeners();
      return true;
    } catch (_) {
      finishLoading();
      return false;
    }
  }
}
