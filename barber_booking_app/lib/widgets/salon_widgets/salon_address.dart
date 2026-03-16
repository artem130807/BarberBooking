import 'package:flutter/material.dart';
import 'package:barber_booking_app/models/vo_models/dto_address_short.dart';

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
        Icon(Icons.location_on, size: 14, color: Theme.of(context).colorScheme.onSurfaceVariant),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            address?.Street ?? 'Адрес не указан',
            style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 14),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (distance != null) ...[
          const SizedBox(width: 12),
          Icon(Icons.directions_walk, size: 14, color: Theme.of(context).colorScheme.onSurfaceVariant),
          const SizedBox(width: 4),
          Text(
            '${distance!.toStringAsFixed(1)} км',
            style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 14),
          ),
        ],
      ],
    );
  }
}