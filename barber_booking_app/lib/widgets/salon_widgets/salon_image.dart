import 'package:flutter/material.dart';

class SalonImage extends StatelessWidget {
  final String? imageUrl;
  final double height;
  final double? width;
  final BoxFit fit;

  const SalonImage({
    super.key,
    this.imageUrl,
    this.height = 120,
    this.width,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
      child: Container(
        height: height,
        width: width ?? double.infinity,
        color: Colors.grey[300],
        child: imageUrl != null && imageUrl!.isNotEmpty
            ? Image.network(
                imageUrl!,
                fit: fit,
                errorBuilder: (_, __, ___) => const Center(
                  child: Icon(Icons.image, size: 40, color: Colors.grey),
                ),
              )
            : const Center(
                child: Icon(Icons.image, size: 40, color: Colors.grey),
              ),
      ),
    );
  }
}