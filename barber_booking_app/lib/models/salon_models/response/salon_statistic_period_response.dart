class SalonStatisticPeriodResponse {
  final String salonId;
  final int completedAppointmentsCount;
  final int cancelledAppointmentsCount;
  final double rating;
  final int ratingCount;

  SalonStatisticPeriodResponse({
    required this.salonId,
    required this.completedAppointmentsCount,
    required this.cancelledAppointmentsCount,
    required this.rating,
    required this.ratingCount,
  });

  factory SalonStatisticPeriodResponse.fromJson(Map<String, dynamic> json) {
    dynamic v(String a, String b) => json[a] ?? json[b];
    final sid = v('salonId', 'SalonId');
    return SalonStatisticPeriodResponse(
      salonId: sid?.toString() ?? '',
      completedAppointmentsCount: _int(v('completedAppointmentsCount', 'CompletedAppointmentsCount')),
      cancelledAppointmentsCount: _int(v('cancelledAppointmentsCount', 'CancelledAppointmentsCount')),
      rating: _double(v('rating', 'Rating')),
      ratingCount: _int(v('ratingCount', 'RatingCount')),
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
