import 'package:flutter/material.dart';

class SalonRating extends StatelessWidget {
  final double rating;
  final int reviewCount;
  final double? size;

  const SalonRating({
    super.key,
    required this.rating,
    required this.reviewCount,
    this.size,
  });

  @override
  Widget build(BuildContext context) {
    final iconSize = size ?? 16.0;
    final fontSize = size != null ? size! * 0.9 : 14.0;

    return Row(
      children: [
        Icon(Icons.star, color: Colors.amber, size: iconSize),
        const SizedBox(width: 4),
        Text(
          rating.toStringAsFixed(1),
          style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.w500),
        ),
        if (reviewCount > 0) ...[
          const SizedBox(width: 4),
          Text(
            '($reviewCount)',
            style: TextStyle(fontSize: fontSize * 0.9, color: Colors.grey),
          ),
        ],
      ],
    );
  }
}