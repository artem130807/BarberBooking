class CreateSalonRequest {
  CreateSalonRequest({
    required this.name,
    required this.description,
    required this.mainPhotoUrl,
    required this.dtoAddress,
    required this.phone,
  });

  final String name;
  final String description;
  final String mainPhotoUrl;
  final CreateSalonAddressDto dtoAddress;
  final CreateSalonPhoneDto phone;

  Map<String, dynamic> toJson() => {
        'name': name,
        'description': description,
        'mainPhotoUrl': mainPhotoUrl,
        'dtoAddress': dtoAddress.toJson(),
        'phone': phone.toJson(),
      };
}

class CreateSalonAddressDto {
  CreateSalonAddressDto({
    required this.city,
    required this.street,
    required this.houseNumber,
    this.apartment,
  });

  final String city;
  final String street;
  final String houseNumber;
  final String? apartment;

  Map<String, dynamic> toJson() => {
        'city': city,
        'street': street,
        'houseNumber': houseNumber,
        if (apartment != null && apartment!.trim().isNotEmpty)
          'apartment': apartment!.trim(),
      };
}

class CreateSalonPhoneDto {
  CreateSalonPhoneDto({required this.number});

  final String number;

  Map<String, dynamic> toJson() => {'number': number};
}
