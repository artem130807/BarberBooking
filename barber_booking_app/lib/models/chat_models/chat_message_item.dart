import 'dart:convert';

class ChatMessageItem {
  ChatMessageItem({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.content,
    required this.isRead,
    required this.sendTime,
  });

  final String id;
  final String senderId;
  final String senderName;
  final String content;
  final bool isRead;
  final DateTime sendTime;

  factory ChatMessageItem.fromJson(Map<String, dynamic> json) {
    dynamic v(String a, String b) => json[a] ?? json[b];
    final sendTimeRaw = v('sendTime', 'SendTime');
    final sendTime = DateTime.tryParse(sendTimeRaw?.toString() ?? '') ??
        DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);

    return ChatMessageItem(
      id: (v('id', 'Id') ?? '').toString(),
      senderId: (v('senderId', 'SenderId') ?? '').toString(),
      senderName: (v('senderName', 'SenderName') ?? '').toString(),
      content: (v('content', 'Content') ?? '').toString(),
      isRead: (v('isRead', 'IsRead') == true) ||
          (v('isRead', 'IsRead')?.toString().toLowerCase() == 'true'),
      sendTime: sendTime,
    );
  }

  static List<ChatMessageItem> listFromBody(String body) {
    final decoded = jsonDecode(body);
    if (decoded is! Map<String, dynamic>) return const [];
    final rawData = decoded['data'] ?? decoded['Data'];
    if (rawData is! List) return const [];
    return rawData
        .map((e) => ChatMessageItem.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList(growable: false);
  }
}
