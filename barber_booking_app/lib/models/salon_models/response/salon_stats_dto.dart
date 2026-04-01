class SalonStatsDto {
  final String salonId;
  final int completedAppointmentsCount;
  final int cancelledAppointmentsCount;
  final int ratingCount;
  final double rating;
  final double sumPrice;
  final DateTime createdAt;

  SalonStatsDto({
    required this.salonId,
    required this.completedAppointmentsCount,
    required this.cancelledAppointmentsCount,
    required this.ratingCount,
    required this.rating,
    required this.sumPrice,
    required this.createdAt,
  });

  factory SalonStatsDto.fromJson(Map<String, dynamic> json) {
    dynamic v(String a, String b) => json[a] ?? json[b];
    final created = v('createdAt', 'CreatedAt');
    DateTime at;
    if (created is String) {
      at = DateTime.tryParse(created) ?? DateTime.fromMillisecondsSinceEpoch(0);
    } else {
      at = DateTime.fromMillisecondsSinceEpoch(0);
    }
    return SalonStatsDto(
      salonId: v('salonId', 'SalonId')?.toString() ?? '',
      completedAppointmentsCount: _int(v('completedAppointmentsCount', 'CompletedAppointmentsCount')),
      cancelledAppointmentsCount: _int(v('cancelledAppointmentsCount', 'CancelledAppointmentsCount')),
      ratingCount: _int(v('ratingCount', 'RatingCount')),
      rating: _double(v('rating', 'Rating')),
      sumPrice: _double(v('sumPrice', 'SumPrice')),
      createdAt: at.isUtc ? at.toLocal() : at,
    );
  }

  static int _int(dynamic x) {
    if (x == null) return 0;
    if (x is int) return x;
    if (x is num) return x.toInt();
    return int.tryParse(x.toString()) ?? 0;
  }

  static double _double(dynamic x) {
    if (x == null) return 0;
    if (x is double) return x;
    if (x is num) return x.toDouble();
    return double.tryParse(x.toString()) ?? 0;
  }
}
