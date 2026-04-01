class DtoPrice {
  double? Value;

  DtoPrice({this.Value});

  static double? _parseValue(dynamic v) {
    if (v == null) return null;
    if (v is double) return v;
    if (v is int) return v.toDouble();
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString());
  }

  factory DtoPrice.fromJson(Map<String, dynamic> json) {
    return DtoPrice(
      Value: _parseValue(json['value'] ?? json['Value']),
    );
  }
}
