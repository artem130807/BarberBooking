import 'package:barber_booking_app/models/vo_models/dto_address.dart';
import 'package:barber_booking_app/models/vo_models/dto_phone.dart';

class SalonAdminStatsResponse {
  String? Id;
  String? Name;
  String? Description;
  DtoAddress? Address;
  DtoPhone? Phone;
  String? MainPhotoUrl;
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
    this.Description,
    this.Address,
    this.Phone,
    this.MainPhotoUrl,
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
    dynamic v(String a, String b) => json[a] ?? json[b];
    final addr = v('address', 'Address');
    final ph = v('phone', 'Phone');
    return SalonAdminStatsResponse(
      Id: v('id', 'Id')?.toString(),
      Name: v('name', 'Name')?.toString(),
      Description: v('description', 'Description')?.toString(),
      Address: addr != null
          ? DtoAddress.fromJson(Map<String, dynamic>.from(addr as Map))
          : null,
      Phone: ph != null
          ? DtoPhone.fromJson(Map<String, dynamic>.from(ph as Map))
          : null,
      MainPhotoUrl: v('mainPhotoUrl', 'MainPhotoUrl')?.toString(),
      IsActive: _parseBool(v('isActive', 'IsActive')),
      Rating: _toDouble(v('rating', 'Rating')),
      RatingCount: _toInt(v('ratingCount', 'RatingCount')),
      CreatedAt: _parseDt(v('createdAt', 'CreatedAt')),
      MastersCount: _toInt(v('mastersCount', 'MastersCount')),
      ServicesCount: _toInt(v('servicesCount', 'ServicesCount')),
      AppointmentsCount: _toInt(v('appointmentsCount', 'AppointmentsCount')),
      ReviewsCount: _toInt(v('reviewsCount', 'ReviewsCount')),
    );
  }

  static bool? _parseBool(dynamic x) {
    if (x == null) return null;
    if (x is bool) return x;
    final s = x.toString().toLowerCase();
    if (s == 'true') return true;
    if (s == 'false') return false;
    return null;
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
