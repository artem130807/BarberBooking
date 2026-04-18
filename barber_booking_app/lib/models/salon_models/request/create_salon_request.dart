class CreateSalonRequest {
  CreateSalonRequest({
    required this.name,
    required this.description,
    this.mainPhotoUrl,
    required this.dtoAddress,
    required this.phone,
  });

  final String name;
  final String description;
  final String? mainPhotoUrl;
  final CreateSalonAddressDto dtoAddress;
  final CreateSalonPhoneDto phone;

  Map<String, dynamic> toJson() {
    final m = <String, dynamic>{
      'name': name,
      'description': description,
      'dtoAddress': dtoAddress.toJson(),
      'phone': phone.toJson(),
    };
    final p = mainPhotoUrl?.trim();
    if (p != null && p.isNotEmpty) m['mainPhotoUrl'] = p;
    return m;
  }
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
