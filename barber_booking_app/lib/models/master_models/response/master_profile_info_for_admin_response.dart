import 'package:barber_booking_app/models/salon_models/response/salon_navigation_response.dart';

/// Соответствует [DtoMasterProfileInfoForAdmin] — профиль мастера для администратора.
class MasterProfileInfoForAdminResponse {
  MasterProfileInfoForAdminResponse({
    this.id,
    this.userName,
    this.salonNavigation,
    this.bio,
    this.specialization,
    this.avatarUrl,
    this.rating,
    this.ratingCount,
    this.masterPhone,
    this.masterEmail,
    this.createdAt,
  });

  final String? id;
  final String? userName;
  final SalonNavigationResponse? salonNavigation;
  final String? bio;
  final String? specialization;
  final String? avatarUrl;
  final double? rating;
  final int? ratingCount;
  final String? masterPhone;
  final String? masterEmail;
  final DateTime? createdAt;

  factory MasterProfileInfoForAdminResponse.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic>? salonMap;
    final rawSalon = json['salonNavigation'] ?? json['SalonNavigation'];
    if (rawSalon is Map) {
      salonMap = Map<String, dynamic>.from(rawSalon);
    }

    return MasterProfileInfoForAdminResponse(
      id: json['id']?.toString() ?? json['Id']?.toString(),
      userName: json['userName'] as String? ?? json['UserName'] as String?,
      salonNavigation: salonMap != null
          ? SalonNavigationResponse.fromJson(salonMap)
          : null,
      bio: json['bio'] as String? ?? json['Bio'] as String?,
      specialization:
          json['specialization'] as String? ?? json['Specialization'] as String?,
      avatarUrl:
          json['avatarUrl'] as String? ?? json['AvatarUrl'] as String?,
      rating: _parseDouble(json['rating'] ?? json['Rating']),
      ratingCount: _parseInt(json['ratingCount'] ?? json['RatingCount']),
      masterPhone:
          json['masterPhone'] as String? ?? json['MasterPhone'] as String?,
      masterEmail:
          json['masterEmail'] as String? ?? json['MasterEmail'] as String?,
      createdAt: _parseDateTime(json['createdAt'] ?? json['CreatedAt']),
    );
  }

  static double? _parseDouble(dynamic v) {
    if (v == null) return null;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString());
  }

  static int? _parseInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse(v.toString());
  }

  static DateTime? _parseDateTime(dynamic v) {
    if (v == null) return null;
    if (v is String) return DateTime.tryParse(v);
    return null;
  }
}
