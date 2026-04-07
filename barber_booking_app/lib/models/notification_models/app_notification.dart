class AppNotification {
  AppNotification({
    required this.id,
    required this.text,
    required this.createdAt,
    this.subtitle,
  });

  final String id;
  final String text;
  final DateTime createdAt;
  /// Например, время с сервера (SignalR).
  final String? subtitle;
}
