import 'package:flutter/material.dart';
import 'package:barber_booking_app/models/review_models/response/get_reviews_salon_response.dart';
import 'package:barber_booking_app/utils/date_formatter.dart';

class  SalonReviewTile extends StatelessWidget {
  final GetReviewsSalonResponse review;
  final VoidCallback? onMasterTap;

  const SalonReviewTile({
    super.key,
    required this.review,
    this.onMasterTap,
  });

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
                    if (review.SalonRating != null)
                      Row(
                        children: [
                          Icon(Icons.star, color: Theme.of(context).colorScheme.primary, size: 14),
                          const SizedBox(width: 2),
                          Text(review.SalonRating.toString(), style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
                        ],
                      ),
                  ],
                ),
                if (review.NavigationResponse != null || review.MasterRating != null) ...[
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: onMasterTap,
                          child: Text(
                            'Мастер: ${review.NavigationResponse?.MasterName ?? 'Неизвестный мастер'}',
                            style: TextStyle(
                              fontSize: 13,
                              color: onMasterTap != null ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurfaceVariant,
                              decoration: onMasterTap != null ? TextDecoration.underline : null,
                            ),
                          ),
                        ),
                      ),
                      if (review.MasterRating != null)
                        Row(
                          children: [
                            Icon(Icons.star, color: Theme.of(context).colorScheme.primary, size: 12),
                            const SizedBox(width: 2),
                            Text(
                              review.MasterRating.toString(),
                              style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant),
                            ),
                          ],
                        ),
                    ],
                  ),
                ],
                const SizedBox(height: 4),
                Text(review.Comment ?? '', style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
                const SizedBox(height: 4),
                Text(
                  DateFormatter.formatDateOnly(review.CreatedAt ?? ''),
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}