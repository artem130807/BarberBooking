import 'package:barber_booking_app/models/VoModels/dto_address.dart';
import 'package:barber_booking_app/models/VoModels/dto_phone.dart';

class GetSalonResponse {
  String? Id;
  String? Name;
  String? Description;
  DtoAddress? Address;
  DtoPhone? Phone;
  String? OpeningTime;
  String? ClosingTime;
  bool?   IsActive;
  String? MainPhotoUrl;
  double? Rating;
  int? RatingCount;
  int? AvailableSlots;

  GetSalonResponse({this.Id, this.Name, this.Description, this.Address, this.Phone, this.OpeningTime, 
  this.ClosingTime, this.IsActive, this.MainPhotoUrl, this.Rating, 
  this.RatingCount, this.AvailableSlots});

  factory GetSalonResponse.fromJson(Map<String, dynamic> json){
      return  GetSalonResponse(
          Id: json['id'],
          Name: json['name'],
          MainPhotoUrl: json['mainPhotoUrl'],
          Rating: json['rating'],
          RatingCount: json['ratingCount'],
          AvailableSlots: json['availableSlots'],
          Address: json['address'] != null
          ? DtoAddress.fromJson(json['address'])
          : null,
      );
    }

}