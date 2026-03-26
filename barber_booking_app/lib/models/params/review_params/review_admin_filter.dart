class ReviewAdminFilter {
  final String? salonId;
  final String? masterId;
  final DateTime? from;
  final DateTime? to;
  final bool prioritizeLowRatings;

  const ReviewAdminFilter({
    this.salonId,
    this.masterId,
    this.from,
    this.to,
    this.prioritizeLowRatings = false,
  });

  static const ReviewAdminFilter empty = ReviewAdminFilter();

  ReviewAdminFilter copyWith({
    String? salonId,
    String? masterId,
    DateTime? from,
    DateTime? to,
    bool? prioritizeLowRatings,
    bool clearSalon = false,
    bool clearMaster = false,
    bool clearPeriod = false,
  }) {
    return ReviewAdminFilter(
      salonId: clearSalon ? null : (salonId ?? this.salonId),
      masterId: clearMaster ? null : (masterId ?? this.masterId),
      from: clearPeriod ? null : (from ?? this.from),
      to: clearPeriod ? null : (to ?? this.to),
      prioritizeLowRatings: prioritizeLowRatings ?? this.prioritizeLowRatings,
    );
  }

  String get widgetKey =>
      '${salonId ?? ''}_${masterId ?? ''}_${from?.millisecondsSinceEpoch ?? 0}_${to?.millisecondsSinceEpoch ?? 0}_$prioritizeLowRatings';

  int get activeCount {
    var n = 0;
    if (salonId != null && salonId!.isNotEmpty) n++;
    if (masterId != null && masterId!.isNotEmpty) n++;
    if (from != null) n++;
    if (to != null) n++;
    if (prioritizeLowRatings) n++;
    return n;
  }
}
