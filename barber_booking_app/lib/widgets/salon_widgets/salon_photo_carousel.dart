import 'package:flutter/material.dart';

class SalonPhotoCarousel extends StatefulWidget {
  const SalonPhotoCarousel({
    super.key,
    required this.imageUrls,
    this.height = 220,
    this.onPageChanged,
    this.borderRadius,
  });

  final List<String> imageUrls;
  final double height;
  final ValueChanged<int>? onPageChanged;
  final BorderRadius? borderRadius;

  @override
  State<SalonPhotoCarousel> createState() => _SalonPhotoCarouselState();
}

class _SalonPhotoCarouselState extends State<SalonPhotoCarousel> {
  late final PageController _controller;
  int _index = 0;

  @override
  void initState() {
    super.initState();
    _controller = PageController();
  }

  @override
  void didUpdateWidget(SalonPhotoCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imageUrls.length != widget.imageUrls.length && _controller.hasClients) {
      final maxI = widget.imageUrls.isEmpty ? 0 : widget.imageUrls.length - 1;
      if (_index > maxI) {
        _index = maxI;
        _controller.jumpToPage(_index);
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final radius = widget.borderRadius ?? BorderRadius.zero;
    final urls = widget.imageUrls;

    Widget placeholder() {
      return ColoredBox(
        color: cs.surfaceContainerHighest,
        child: Center(
          child: Icon(
            Icons.storefront_outlined,
            size: 56,
            color: cs.onSurfaceVariant,
          ),
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ClipRRect(
          borderRadius: radius,
          child: SizedBox(
            height: widget.height,
            width: double.infinity,
            child: urls.isEmpty
                ? placeholder()
                : PageView.builder(
                    controller: _controller,
                    itemCount: urls.length,
                    onPageChanged: (i) {
                      setState(() => _index = i);
                      widget.onPageChanged?.call(i);
                    },
                    itemBuilder: (context, i) {
                      final u = urls[i];
                      return Image.network(
                        u,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: widget.height,
                        errorBuilder: (_, __, ___) => placeholder(),
                        loadingBuilder: (context, child, progress) {
                          if (progress == null) return child;
                          return ColoredBox(
                            color: cs.surfaceContainerHighest,
                            child: Center(
                              child: SizedBox(
                                width: 28,
                                height: 28,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: cs.primary,
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
        ),
        if (urls.length > 1) ...[
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(urls.length, (i) {
              final active = i == _index;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: active ? 18 : 7,
                height: 7,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  color: active ? cs.primary : cs.outline.withValues(alpha: 0.45),
                ),
              );
            }),
          ),
        ],
      ],
    );
  }
}
