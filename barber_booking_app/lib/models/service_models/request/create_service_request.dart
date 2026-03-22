class CreateServiceRequest {
  final String salonId;
  final String name;
  final String? description;
  final int durationMinutes;
  final double priceValue;
  final String? photoUrl;

  CreateServiceRequest({
    required this.salonId,
    required this.name,
    this.description,
    required this.durationMinutes,
    required this.priceValue,
    this.photoUrl,
  });

  Map<String, dynamic> toJson() => {
        'salonId': salonId,
        'name': name,
        if (description != null && description!.isNotEmpty)
          'description': description,
        'durationMinutes': durationMinutes,
        'price': {'value': priceValue},
        if (photoUrl != null && photoUrl!.isNotEmpty) 'photoUrl': photoUrl,
      };
}
