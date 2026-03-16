import 'package:flutter/material.dart';
import 'package:barber_booking_app/models/vo_models/dto_address.dart';

class SalonFullAddress extends StatelessWidget {
  final DtoAddress? address;
  final double? distance;
  final bool showDistance;

  const SalonFullAddress({
    super.key,
    this.address,
    this.distance,
    this.showDistance = true,
  });

  String _formatAddress() {
    if (address == null) return 'Адрес не указан';
    
    List<String> parts = [];
    if (address!.City?.isNotEmpty == true) parts.add(address!.City!);
    if (address!.Street?.isNotEmpty == true) parts.add('ул. ${address!.Street}');
    if (address!.HouseNumber?.isNotEmpty == true) parts.add('д. ${address!.HouseNumber}');
    if (address!.Apartment?.isNotEmpty == true) parts.add('кв. ${address!.Apartment}');
    
    return parts.isNotEmpty ? parts.join(', ') : 'Адрес не указан';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Адрес',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.location_on, size: 16, color: Theme.of(context).colorScheme.onSurfaceVariant),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                _formatAddress(),
                style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(context).colorScheme.onSurface,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
        if (showDistance && distance != null) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.directions_walk, size: 16, color: Theme.of(context).colorScheme.onSurfaceVariant),
              const SizedBox(width: 8),
              Text(
                '${distance!.toStringAsFixed(1)} км от вас',
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}