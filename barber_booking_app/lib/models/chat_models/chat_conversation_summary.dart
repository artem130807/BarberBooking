import 'dart:convert';

class ChatConversationSummary {
  ChatConversationSummary({
    required this.id,
    required this.userName,
    required this.unreadCount,
    this.lastMessageContent,
    this.lastMessageAt,
  });

  final String id;
  final String userName;
  final int unreadCount;
  final String? lastMessageContent;
  final DateTime? lastMessageAt;

  factory ChatConversationSummary.fromJson(Map<String, dynamic> json) {
    dynamic v(String a, String b) => json[a] ?? json[b];
    final id = (v('id', 'Id') ?? '').toString();
    final name = (v('userName', 'UserName') ?? '').toString();
    final unreadRaw = v('countUreadMessages', 'CountUreadMessages');
    final message = v('lastMessageContent', 'LastMessageContent')?.toString();
    final lastAtRaw = v('lastMessageAt', 'LastMessageAt');

    return ChatConversationSummary(
      id: id,
      userName: name,
      unreadCount: unreadRaw is int
          ? unreadRaw
          : int.tryParse(unreadRaw?.toString() ?? '') ?? 0,
      lastMessageContent:
          message == null || message.trim().isEmpty ? null : message,
      lastMessageAt:
          lastAtRaw == null ? null : DateTime.tryParse(lastAtRaw.toString()),
    );
  }

  static List<ChatConversationSummary> listFromBody(String body) {
    final decoded = jsonDecode(body);
    if (decoded is! Map<String, dynamic>) return const [];
    final rawData = decoded['data'] ?? decoded['Data'];
    if (rawData is! List) return const [];
    return rawData
        .map((e) => ChatConversationSummary.fromJson(
              Map<String, dynamic>.from(e as Map),
            ))
        .toList(growable: false);
  }
}

