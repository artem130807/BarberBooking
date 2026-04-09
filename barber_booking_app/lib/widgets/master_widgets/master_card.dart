import 'package:flutter/material.dart';

class MasterCard extends StatelessWidget {
  final String name;
  final String specialty;
  final double rating;
  final int? ratingCount;
  final String? imageUrl;
  final VoidCallback? onTap;

  const MasterCard({
    super.key,
    required this.name,
    required this.specialty,
    required this.rating,
    this.ratingCount,
    this.imageUrl,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 120,
        margin: const EdgeInsets.only(right: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
                image: imageUrl != null
                    ? DecorationImage(
                        image: NetworkImage(imageUrl!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: imageUrl == null
                  ? Center(
                      child: Icon(Icons.person, size: 40, color: Theme.of(context).colorScheme.onSurfaceVariant),
                    )
                  : null,
            ),
            const SizedBox(height: 8),
            Text(
              name,
              style: const TextStyle(fontWeight: FontWeight.bold),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              specialty,
              style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 12),
            ),
            Row(
              children: [
                const Icon(Icons.star, color: Colors.amber, size: 14),
                const SizedBox(width: 4),
                Text(rating.toStringAsFixed(1), style: const TextStyle(fontSize: 12)),
                if (ratingCount != null) ...[
                  const SizedBox(width: 4),
                  Text(
                    '($ratingCount)',
                    style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}