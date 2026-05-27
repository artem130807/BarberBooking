import 'dart:convert';

import 'package:barber_booking_app/config/api_config.dart';
import 'package:barber_booking_app/models/chat_models/chat_message_item.dart';
import 'package:barber_booking_app/services/auth_services/auth_http_headers.dart';
import 'package:http/http.dart' as http;

class ChatMessageService {
  Future<List<ChatMessageItem>> getMessages(
    String conversationId, {
    int page = 1,
    int pageSize = 100,
  }) async {
    final headers = await AuthHttpHeaders.bearerJson();
    if (headers == null) return const [];

    final uri = Uri.parse(
      '$kApiBaseUrl/api/ConversationMessage/Get-Messages/$conversationId',
    ).replace(queryParameters: {
      'Page': '$page',
      'PageSize': '$pageSize',
    });

    try {
      final response = await http.get(uri, headers: headers);
      if (response.statusCode != 200) return const [];
      final list = ChatMessageItem.listFromBody(response.body).toList();
      list.sort((a, b) => a.sendTime.compareTo(b.sendTime));
      return list;
    } catch (_) {
      return const [];
    }
  }

  Future<bool> sendMessage(
    String conversationId,
    String content,
  ) async {
    final headers = await AuthHttpHeaders.bearerJson();
    if (headers == null) return false;

    final uri = Uri.parse('$kApiBaseUrl/api/ConversationMessage/Create-message');

    try {
      final response = await http.post(
        uri,
        headers: headers,
        body: jsonEncode({
          'conversationId': conversationId,
          'content': content,
        }),
      );
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}

