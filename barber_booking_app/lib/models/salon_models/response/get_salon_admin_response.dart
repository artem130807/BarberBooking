import 'package:barber_booking_app/models/salon_models/response/get_salons_response.dart';
import 'package:barber_booking_app/models/salon_models/response/salon_navigation_response.dart';
import 'package:barber_booking_app/models/vo_models/dto_address_short.dart';

class GetSalonAdminResponse {
  GetSalonAdminResponse({this.navigation});

  final SalonNavigationResponse? navigation;

  String? get salonId => navigation?.Id;

  factory GetSalonAdminResponse.fromJson(Map<String, dynamic> json) {
    final navRaw = json['dtoSalonNavigation'] ?? json['DtoSalonNavigation'];
    SalonNavigationResponse? nav;
    if (navRaw is Map<String, dynamic>) {
      nav = SalonNavigationResponse.fromJson(navRaw);
    } else if (navRaw is Map) {
      nav = SalonNavigationResponse.fromJson(
        Map<String, dynamic>.from(navRaw),
      );
    }
    return GetSalonAdminResponse(navigation: nav);
  }

  GetSalonsResponse toGetSalonsResponse() {
    final n = navigation;
    if (n == null) {
      return GetSalonsResponse();
    }
    return GetSalonsResponse(
      Id: n.Id,
      Name: n.SalonName,
      MainPhotoUrl: n.MainPhotoUrl,
      Rating: n.Rating,
      RatingCount: n.RatingCount,
      Address: n.Address != null
          ? DtoAddressShort(Street: n.Address!.Street)
          : null,
    );
  }
}
