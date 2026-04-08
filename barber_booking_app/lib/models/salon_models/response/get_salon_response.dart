import 'package:barber_booking_app/models/vo_models/dto_address.dart';
import 'package:barber_booking_app/models/vo_models/dto_phone.dart';

class GetSalonResponse {
  String? Id;
  String? Name;
  String? Description;
  DtoAddress? Address;
  DtoPhone? Phone;
  String? OpeningTime;
  String? ClosingTime;
  bool?  IsActive;
  String? MainPhotoUrl;
  double? Rating;
  int? RatingCount;

  GetSalonResponse({this.Id, this.Name, this.Description, this.Address, this.Phone, this.OpeningTime, 
  this.ClosingTime, this.IsActive, this.MainPhotoUrl, this.Rating, 
  this.RatingCount});

  factory GetSalonResponse.fromJson(Map<String, dynamic> json) {
    dynamic v(String a, String b) => json[a] ?? json[b];
    final ot = v('openingTime', 'OpeningTime');
    final ct = v('closingTime', 'ClosingTime');
    return GetSalonResponse(
      Id: v('id', 'Id')?.toString(),
      Name: v('name', 'Name')?.toString(),
      Description: v('description', 'Description')?.toString(),
      Address: v('address', 'Address') != null
          ? DtoAddress.fromJson(Map<String, dynamic>.from(v('address', 'Address') as Map))
          : null,
      Phone: v('phone', 'Phone') != null
          ? DtoPhone.fromJson(Map<String, dynamic>.from(v('phone', 'Phone') as Map))
          : null,
      OpeningTime: ot != null ? ot.toString() : null,
      ClosingTime: ct != null ? ct.toString() : null,
      IsActive: v('isActive', 'IsActive') as bool?,
      MainPhotoUrl: v('mainPhotoUrl', 'MainPhotoUrl')?.toString(),
      Rating: (v('rating', 'Rating') as num?)?.toDouble(),
      RatingCount: _parseInt(v('ratingCount', 'RatingCount')),
    );
  }

  static int? _parseInt(dynamic x) {
    if (x == null) return null;
    if (x is int) return x;
    if (x is num) return x.toInt();
    return int.tryParse(x.toString());
  }

}