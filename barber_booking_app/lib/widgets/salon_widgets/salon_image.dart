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
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        child: imageUrl != null && imageUrl!.isNotEmpty
            ? Image.network(
                imageUrl!,
                fit: fit,
                errorBuilder: (_, __, ___) => Center(
                  child: Icon(Icons.image, size: 40, color: Theme.of(context).colorScheme.onSurfaceVariant),
                ),
              )
            : Center(
                child: Icon(Icons.image, size: 40, color: Theme.of(context).colorScheme.onSurfaceVariant),
              ),
      ),
    );
  }
}