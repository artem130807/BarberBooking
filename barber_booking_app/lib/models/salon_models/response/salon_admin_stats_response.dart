class SalonAdminStatsResponse {
  String? Id;
  String? Name;
  bool? IsActive;
  double? Rating;
  int? RatingCount;
  DateTime? CreatedAt;
  int? MastersCount;
  int? ServicesCount;
  int? AppointmentsCount;
  int? ReviewsCount;

  SalonAdminStatsResponse({
    this.Id,
    this.Name,
    this.IsActive,
    this.Rating,
    this.RatingCount,
    this.CreatedAt,
    this.MastersCount,
    this.ServicesCount,
    this.AppointmentsCount,
    this.ReviewsCount,
  });

  factory SalonAdminStatsResponse.fromJson(Map<String, dynamic> json) {
    return SalonAdminStatsResponse(
      Id: json['id']?.toString(),
      Name: json['name']?.toString(),
      IsActive: json['isActive'] is bool ? json['isActive'] as bool : null,
      Rating: _toDouble(json['rating']),
      RatingCount: _toInt(json['ratingCount']),
      CreatedAt: _parseDt(json['createdAt']),
      MastersCount: _toInt(json['mastersCount']),
      ServicesCount: _toInt(json['servicesCount']),
      AppointmentsCount: _toInt(json['appointmentsCount']),
      ReviewsCount: _toInt(json['reviewsCount']),
    );
  }

  static double? _toDouble(dynamic v) {
    if (v == null) return null;
    if (v is double) return v;
    if (v is int) return v.toDouble();
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString());
  }

  static int? _toInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse(v.toString());
  }

  static DateTime? _parseDt(dynamic v) {
    if (v == null) return null;
    return DateTime.tryParse(v.toString());
  }
}
