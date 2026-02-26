import 'package:flutter/material.dart';

class MasterCard extends StatelessWidget {
  final String name;
  final String specialty;
  final double rating;
  final String? imageUrl;

  const MasterCard({
    super.key,
    required this.name,
    required this.specialty,
    required this.rating,
    this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      margin: const EdgeInsets.only(right: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(12),
              image: imageUrl != null
                  ? DecorationImage(
                      image: NetworkImage(imageUrl!),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: imageUrl == null
                ? const Center(
                    child: Icon(Icons.person, size: 40, color: Colors.grey),
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
            style: const TextStyle(color: Colors.grey, fontSize: 12),
          ),
          Row(
            children: [
              const Icon(Icons.star, color: Colors.amber, size: 14),
              const SizedBox(width: 4),
              Text(rating.toStringAsFixed(1), style: const TextStyle(fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }
}