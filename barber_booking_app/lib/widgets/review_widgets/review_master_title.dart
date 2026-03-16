import 'package:flutter/material.dart';
import 'package:barber_booking_app/models/review_models/response/get_reviews_master_response.dart';
import 'package:barber_booking_app/utils/date_formatter.dart';

class ReviewMasterTitle extends StatelessWidget {
  final GetReviewsMasterResponse review;

  const ReviewMasterTitle({super.key, required this.review});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
            child: Icon(Icons.person, size: 20, color: Theme.of(context).colorScheme.onSurfaceVariant),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        review.UserName ?? 'Аноним',
                        style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface),
                      ),
                    ),
                    Row(
                      children: [
                        Icon(Icons.star, color: Theme.of(context).colorScheme.primary, size: 14),
                        const SizedBox(width: 2),
                        Text(review.MasterRating?.toString() ?? '0', style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(review.Comment ?? '', style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
                const SizedBox(height: 4),
                Text(
                  DateFormatter.formatDateOnly(review.CreatedAt ?? ''),
                  style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}