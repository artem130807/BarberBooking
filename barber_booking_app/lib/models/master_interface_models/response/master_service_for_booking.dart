import 'package:barber_booking_app/models/vo_models/dto_price.dart';

class MasterServiceForBooking {
  final String id;
  final String name;
  final int durationMinutes;
  final DtoPrice? price;

  const MasterServiceForBooking({
    required this.id,
    required this.name,
    required this.durationMinutes,
    this.price,
  });

  factory MasterServiceForBooking.fromJson(Map<String, dynamic> json) {
    dynamic v(String a, String b) => json[a] ?? json[b];
    final priceRaw = v('price', 'Price');
    return MasterServiceForBooking(
      id: v('id', 'Id')?.toString() ?? '',
      name: v('name', 'Name')?.toString() ?? '',
      durationMinutes: _parseInt(v('durationMinutes', 'DurationMinutes')) ?? 30,
      price: priceRaw != null
          ? DtoPrice.fromJson(Map<String, dynamic>.from(priceRaw as Map))
          : null,
    );
  }

  static int? _parseInt(dynamic x) {
    if (x == null) return null;
    if (x is int) return x;
    if (x is num) return x.toInt();
    return int.tryParse(x.toString());
  }
}
