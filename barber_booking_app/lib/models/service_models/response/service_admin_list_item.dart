import 'package:barber_booking_app/models/vo_models/dto_price.dart';

class ServiceAdminListItem {
  String? Id;
  String? SalonId;
  String? Name;
  String? Description;
  int? DurationMinutes;
  DtoPrice? Price;
  String? PhotoUrl;
  bool? IsActive;
  DateTime? CreatedAt;

  ServiceAdminListItem({
    this.Id,
    this.SalonId,
    this.Name,
    this.Description,
    this.DurationMinutes,
    this.Price,
    this.PhotoUrl,
    this.IsActive,
    this.CreatedAt,
  });

  factory ServiceAdminListItem.fromJson(Map<String, dynamic> json) {
    return ServiceAdminListItem(
      Id: json['id']?.toString(),
      SalonId: json['salonId']?.toString(),
      Name: json['name']?.toString(),
      Description: json['description']?.toString(),
      DurationMinutes: _toInt(json['durationMinutes']),
      Price: json['price'] != null
          ? DtoPrice.fromJson(Map<String, dynamic>.from(json['price'] as Map))
          : null,
      PhotoUrl: json['photoUrl']?.toString(),
      IsActive: json['isActive'] is bool ? json['isActive'] as bool : null,
      CreatedAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
    );
  }

  static int? _toInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse(v.toString());
  }
}
