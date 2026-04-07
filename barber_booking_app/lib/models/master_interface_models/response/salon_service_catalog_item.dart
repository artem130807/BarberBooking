import 'package:barber_booking_app/models/vo_models/dto_price.dart';

class SalonServiceCatalogItem {
  SalonServiceCatalogItem({
    required this.id,
    required this.name,
    this.durationMinutes,
    this.priceValue,
    this.isActive,
  });

  final String id;
  final String name;
  final int? durationMinutes;
  final double? priceValue;
  final bool? isActive;

  factory SalonServiceCatalogItem.fromJson(Map<String, dynamic> json) {
    dynamic v(String a, String b) => json[a] ?? json[b];
    final ia = v('isActive', 'IsActive');
    bool? active;
    if (ia is bool) {
      active = ia;
    } else if (ia != null) {
      active = ia == true || ia.toString().toLowerCase() == 'true';
    }
    final dm = v('durationMinutes', 'DurationMinutes');
    int? d;
    if (dm is int) {
      d = dm;
    } else if (dm != null) {
      d = int.tryParse(dm.toString());
    }
    final priceRaw = v('price', 'Price');
    double? pv;
    if (priceRaw is Map) {
      pv = DtoPrice.fromJson(Map<String, dynamic>.from(priceRaw)).Value;
    }
    return SalonServiceCatalogItem(
      id: v('id', 'Id')?.toString() ?? '',
      name: v('name', 'Name')?.toString() ?? '',
      durationMinutes: d,
      priceValue: pv,
      isActive: active,
    );
  }
}
