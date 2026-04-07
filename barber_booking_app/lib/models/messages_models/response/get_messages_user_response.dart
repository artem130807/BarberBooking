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
    final idRaw = json['id'] ?? json['Id'];
    final id = idRaw is String ? idRaw : idRaw?.toString() ?? '';
    final content =
        (json['content'] ?? json['Content'] ?? '') as String;
    final createdRaw = json['createdAt'] ?? json['CreatedAt'];
    DateTime createdAt;
    if (createdRaw is String) {
      createdAt = DateTime.parse(createdRaw);
    } else {
      createdAt = DateTime.now();
    }
    return GetMessagesUserResponse(
      id: id,
      content: content,
      createdAt: createdAt,
    );
  }
}
