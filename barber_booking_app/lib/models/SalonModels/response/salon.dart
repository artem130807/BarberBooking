import 'package:barber_booking_app/models/SalonModels/response/get_salon_response.dart';
import 'package:barber_booking_app/models/VoModels/dto_address.dart';
import 'package:barber_booking_app/models/VoModels/dto_phone.dart';

class Salon {
  String? id;
  String? name;
  String? description;
  DtoAddress? address;
  DtoPhone? phone;
  String? openingTime;
  String? closingTime;
  String?  active;
  String? mainPhotoUrl;
  double? rating;
  int? ratingCount;

    Salon._({
    this.id, 
    this.name, 
    this.description, 
    this.address, 
    this.phone, 
    this.openingTime, 
    this.closingTime, 
    this.active, 
    this.mainPhotoUrl, 
    this.rating, 
    this.ratingCount
  });

  factory Salon.fromResponse(GetSalonResponse response) {
    return Salon._(
      id: response.Id,
      name: response.Name,
      description: response.Description,
      address: response.Address,
      phone: response.Phone,
      openingTime: response.OpeningTime,
      closingTime: response.ClosingTime,
      mainPhotoUrl: response.MainPhotoUrl,
      rating: response.Rating,
      ratingCount: response.RatingCount,
      active: response.IsActive == true ? "Ресторан активен" : "Ресторан неактивен"
    );
  }
}
