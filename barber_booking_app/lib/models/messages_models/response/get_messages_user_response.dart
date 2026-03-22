class GetMessagesUserResponse {
  final String id;
  final String content;
  final DateTime createdAt;

  GetMessagesUserResponse({
    required this.id,
    required this.content,
    required this.createdAt,
  });

  factory GetMessagesUserResponse.fromJson(Map<String, dynamic> json) {
    return GetMessagesUserResponse(
      id: json['id'] as String,
      content: (json['content'] ?? '') as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}
