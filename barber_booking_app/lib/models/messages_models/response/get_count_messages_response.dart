class GetCountMessagesResponse {
  final int count;

  GetCountMessagesResponse({required this.count});

  factory GetCountMessagesResponse.fromJson(dynamic json) {
    if (json is int) {
      return GetCountMessagesResponse(count: json);
    }
    return GetCountMessagesResponse(count: 0);
  }
}
