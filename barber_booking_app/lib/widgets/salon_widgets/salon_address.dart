import 'package:flutter/material.dart';
import 'package:barber_booking_app/models/VoModels/dto_address_short.dart';

class SalonAddress extends StatelessWidget {
  final DtoAddressShort? address;
  final double? distance;

  const SalonAddress({
    super.key,
    this.address,
    this.distance,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.location_on, size: 14, color: Colors.grey),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            address?.Street ?? 'Адрес не указан',
            style: const TextStyle(color: Colors.grey, fontSize: 14),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (distance != null) ...[
          const SizedBox(width: 12),
          const Icon(Icons.directions_walk, size: 14, color: Colors.grey),
          const SizedBox(width: 4),
          Text(
            '${distance!.toStringAsFixed(1)} км',
            style: const TextStyle(color: Colors.grey, fontSize: 14),
          ),
        ],
      ],
    );
  }
}