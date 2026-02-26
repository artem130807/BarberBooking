

import 'package:barber_booking_app/models/VoModels/dto_address_short.dart';

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
      return GetSalonsResponse(
          Id: json['id'],
          Name: json['name'],
          MainPhotoUrl: json['mainPhotoUrl'],
          Rating: json['rating'],
          RatingCount: json['ratingCount'],
          AvailableSlots: json['availableSlots'],
          Address: json['address'] != null
          ? DtoAddressShort.fromJson(json['address'])
          : null,
      );
    }
  
}