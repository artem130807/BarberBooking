class UpdateSalonRequest {
  UpdateSalonRequest({
    this.name,
    this.description,
    this.mainPhotoUrl,
    this.address,
    this.phoneNumber,
  });

  final String? name;
  final String? description;
  final String? mainPhotoUrl;
  final UpdateSalonAddressRequest? address;
  final UpdateSalonPhoneRequest? phoneNumber;

  Map<String, dynamic> toJson() {
    final m = <String, dynamic>{};
    if (name != null) m['name'] = name;
    if (description != null) m['description'] = description;
    if (mainPhotoUrl != null) m['mainPhotoUrl'] = mainPhotoUrl;
    if (address != null) m['address'] = address!.toJson();
    if (phoneNumber != null && phoneNumber!.hasValue) {
      m['phoneNumber'] = phoneNumber!.toJson();
    }
    return m;
  }
}

class UpdateSalonAddressRequest {
  UpdateSalonAddressRequest({
    this.city,
    this.street,
    this.houseNumber,
    this.apartment,
  });

  final String? city;
  final String? street;
  final String? houseNumber;
  final String? apartment;

  Map<String, dynamic> toJson() {
    final m = <String, dynamic>{};
    if (city != null) m['city'] = city;
    if (street != null) m['street'] = street;
    if (houseNumber != null) m['houseNumber'] = houseNumber;
    if (apartment != null) m['apartment'] = apartment;
    return m;
  }
}

class UpdateSalonPhoneRequest {
  UpdateSalonPhoneRequest({this.number});

  final String? number;

  bool get hasValue => number != null && number!.trim().isNotEmpty;

  Map<String, dynamic> toJson() => {'number': number};
}
