import 'package:barber_booking_app/widgets/booking_button.dart';
import 'package:barber_booking_app/widgets/salon_widgets/salon_address.dart';
import 'package:barber_booking_app/widgets/salon_widgets/salon_image.dart';
import 'package:barber_booking_app/widgets/salon_widgets/salon_rating.dart';
import 'package:flutter/material.dart';
import 'package:barber_booking_app/models/SalonModels/response/get_salons_response.dart';


class SalonCard extends StatelessWidget {
  final GetSalonsResponse salon;
  final VoidCallback? onTap;
  final VoidCallback? onBooking;

  const SalonCard({
    super.key,
    required this.salon,
    this.onTap,
    this.onBooking,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            SalonImage(imageUrl: salon.MainPhotoUrl),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          salon.Name ?? 'Без названия',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (salon.Rating != null)
                        SalonRating(
                          rating: salon.Rating!,
                          reviewCount: salon.RatingCount ?? 0,
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  SalonAddress(address: salon.Address),
                  if (salon.AvailableSlots != null) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.event_available, size: 14, color: Colors.green),
                        const SizedBox(width: 4),
                        Text(
                          'Доступно слотов: ${salon.AvailableSlots}',
                          style: const TextStyle(
                            color: Colors.green,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 12),
                  BookingButton(onPressed: onBooking),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}