class SalonCreateInfoResponse {
  SalonCreateInfoResponse({this.id});

  final String? id;

  factory SalonCreateInfoResponse.fromJson(Map<String, dynamic> json) {
    final raw = json['id'] ?? json['Id'];
    return SalonCreateInfoResponse(
      id: raw?.toString(),
    );
  }
}
