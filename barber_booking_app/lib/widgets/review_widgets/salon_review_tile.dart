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
            backgroundColor: Colors.grey[300],
            child: const Icon(Icons.person, size: 20, color: Colors.grey),
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
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    if (review.SalonRating != null)
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 14),
                          const SizedBox(width: 2),
                          Text(review.SalonRating.toString()),
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
                              color: onMasterTap != null ? Colors.blue : Colors.grey,
                              decoration: onMasterTap != null ? TextDecoration.underline : null,
                            ),
                          ),
                        ),
                      ),
                      if (review.MasterRating != null)
                        Row(
                          children: [
                            const Icon(Icons.star, color: Colors.amber, size: 12),
                            const SizedBox(width: 2),
                            Text(
                              review.MasterRating.toString(),
                              style: const TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                          ],
                        ),
                    ],
                  ),
                ],
                const SizedBox(height: 4),
                Text(review.Comment ?? ''),
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