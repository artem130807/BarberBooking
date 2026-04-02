class MasterStatisticResponse {
  MasterStatisticResponse({
    this.masterProfileId,
    this.completedAppointmentsCount,
    this.cancelledAppointmentsCount,
    this.rating,
    this.ratingCount,
    this.sumPrice,
  });

  String? masterProfileId;
  int? completedAppointmentsCount;
  int? cancelledAppointmentsCount;
  double? rating;
  int? ratingCount;
  double? sumPrice;

  factory MasterStatisticResponse.fromJson(Map<String, dynamic> json) {
    dynamic v(String a, String b) => json[a] ?? json[b];
    return MasterStatisticResponse(
      masterProfileId: v('masterProfileId', 'MasterProfileId')?.toString(),
      completedAppointmentsCount: _i(v('completedAppointmentsCount', 'CompletedAppointmentsCount')),
      cancelledAppointmentsCount: _i(v('cancelledAppointmentsCount', 'CancelledAppointmentsCount')),
      rating: _d(v('rating', 'Rating')),
      ratingCount: _i(v('ratingCount', 'RatingCount')),
      sumPrice: _d(v('sumPrice', 'SumPrice')),
    );
  }

  static double? _d(dynamic x) {
    if (x == null) return null;
    if (x is double) return x;
    if (x is int) return x.toDouble();
    if (x is num) return x.toDouble();
    return double.tryParse(x.toString());
  }

  static int? _i(dynamic x) {
    if (x == null) return null;
    if (x is int) return x;
    if (x is num) return x.toInt();
    return int.tryParse(x.toString());
  }
}
