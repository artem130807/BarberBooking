

import 'package:barber_booking_app/models/vo_models/dto_address_short.dart';

class GetSalonsResponse {

  final String? Id;
  final String? Name;
  final String? MainPhotoUrl;
  final double? Rating;
  final int? RatingCount;
  final int? AvailableSlots;
  final DtoAddressShort? Address;

  GetSalonsResponse({this.Id, this.Name, this.MainPhotoUrl, this.Rating, this.RatingCount, this.AvailableSlots, this.Address});
  
   factory GetSalonsResponse.fromJson(Map<String, dynamic> json){
      dynamic v(String a, String b) => json[a] ?? json[b];
      final addr = v('address', 'Address');
      return GetSalonsResponse(
          Id: v('id', 'Id')?.toString(),
          Name: v('name', 'Name')?.toString(),
          MainPhotoUrl: v('mainPhotoUrl', 'MainPhotoUrl')?.toString(),
          Rating: (v('rating', 'Rating') as num?)?.toDouble(),
          RatingCount: _parseInt(v('ratingCount', 'RatingCount')),
          AvailableSlots: _parseInt(v('availableSlots', 'AvailableSlots')),
          Address: addr != null
          ? DtoAddressShort.fromJson(Map<String, dynamic>.from(addr as Map))
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