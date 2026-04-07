import 'package:flutter/material.dart';

RoundedRectangleBorder profileCardShape(ColorScheme colorScheme) {
  return RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(12),
    side: BorderSide(color: colorScheme.outline.withValues(alpha: 0.2)),
  );
}

class ProfileSectionHeading extends StatelessWidget {
  const ProfileSectionHeading({
    super.key,
    required this.text,
    required this.colorScheme,
  });

  final String text;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        text,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurfaceVariant,
              letterSpacing: 0.2,
            ),
      ),
    );
  }
}

class ProfileLabeledRow extends StatelessWidget {
  const ProfileLabeledRow({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
    required this.colorScheme,
    this.valueMaxLines = 3,
    this.valueWidget,
  });

  final IconData icon;
  final String title;
  final String value;
  final ColorScheme colorScheme;
  final int valueMaxLines;
  final Widget? valueWidget;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer.withValues(alpha: 0.65),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: colorScheme.primary, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.1,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 4),
                valueWidget ??
                    Text(
                      value,
                      maxLines: valueMaxLines,
                      overflow: TextOverflow.ellipsis,
                      style: tt.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        height: 1.35,
                      ),
                    ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
