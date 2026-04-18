import 'package:barber_booking_app/models/base/base_provider.dart';
import 'package:barber_booking_app/models/messages_models/response/get_messages_user_response.dart';
import 'package:barber_booking_app/services/messages_services/delete_message_service.dart';
import 'package:barber_booking_app/services/messages_services/get_message_user_service.dart';

class GetMessageUserProvider extends BaseProvider {
  final GetMessageUserService _service = GetMessageUserService();
  final DeleteMessageService _deleteService = DeleteMessageService();

  List<GetMessagesUserResponse> _messages = [];
  List<GetMessagesUserResponse> get messages => _messages;

  Future<bool> loadMessages() async {
    startLoading();
    try {
      final response = await _service.getMessages();
      _messages = response ?? [];
      finishLoading();
      notifyListeners();
      return true;
    } catch (_) {
      finishLoading();
      return false;
    }
  }

  Future<String?> deleteMessage(String messageId) async {
    final error = await _deleteService.deleteMessage(messageId);
    if (error == null) {
      _messages.removeWhere((m) => m.id == messageId);
      notifyListeners();
    }
    return error;
  }
}
