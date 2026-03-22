class UpdateServiceRequest {
  final String? name;
  final String? description;
  final int? durationMinutes;
  final double? priceValue;
  final String? photo;
  final bool? isActive;

  UpdateServiceRequest({
    this.name,
    this.description,
    this.durationMinutes,
    this.priceValue,
    this.photo,
    this.isActive,
  });

  Map<String, dynamic> toJson() {
    final m = <String, dynamic>{};
    if (name != null) m['name'] = name;
    if (description != null) m['description'] = description;
    if (durationMinutes != null) m['durationMinutes'] = durationMinutes;
    if (priceValue != null) m['price'] = {'value': priceValue};
    if (photo != null) m['photo'] = photo;
    if (isActive != null) m['isActive'] = isActive;
    return m;
  }
}
