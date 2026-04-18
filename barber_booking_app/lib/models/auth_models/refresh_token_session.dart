class RefreshTokenSession {
  RefreshTokenSession({
    required this.id,
    required this.devices,
  });

  final String id;
  final String devices;

  factory RefreshTokenSession.fromJson(Map<String, dynamic> json) {
    final idRaw = json['id'];
    final id = idRaw is String ? idRaw : idRaw?.toString() ?? '';
    return RefreshTokenSession(
      id: id,
      devices: json['devices'] as String? ?? '',
    );
  }
}
