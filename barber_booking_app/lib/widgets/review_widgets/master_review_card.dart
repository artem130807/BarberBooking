import 'package:barber_booking_app/models/review_models/response/get_reviews_master_response.dart';
import 'package:barber_booking_app/utils/date_formatter.dart';
import 'package:flutter/material.dart';

class MasterReviewCard extends StatelessWidget {
  const MasterReviewCard({
    super.key,
    required this.review,
    required this.colorScheme,
  });

  final GetReviewsMasterResponse review;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final created = review.CreatedAt;
    final dateLabel = created != null && created.isNotEmpty
        ? DateFormatter.formatDateOnly(created)
        : '—';

    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: colorScheme.outline.withValues(alpha: 0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: colorScheme.secondaryContainer,
              child: Icon(
                Icons.person_rounded,
                color: colorScheme.onSecondaryContainer,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          review.UserName ?? 'Клиент',
                          style: tt.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.star_rounded,
                            color: colorScheme.primary,
                            size: 18,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${review.MasterRating ?? 0}',
                            style: tt.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  if (review.Comment != null &&
                      review.Comment!.trim().isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      review.Comment!.trim(),
                      style: TextStyle(
                        color: colorScheme.onSurfaceVariant,
                        height: 1.4,
                        fontSize: 14,
                      ),
                    ),
                  ],
                  const SizedBox(height: 8),
                  Text(
                    dateLabel,
                    style: TextStyle(
                      fontSize: 12,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
