import 'package:barber_booking_app/utils/phone_launch.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Номер как действие: тап — звонок, иконка — копирование.
class PhoneTapBar extends StatelessWidget {
  const PhoneTapBar({
    super.key,
    required this.phone,
    this.style,
    this.dense = false,
    this.showDialIcon = true,
  });

  final String phone;
  final TextStyle? style;
  final bool dense;

  /// Если рядом уже есть иконка телефона — передайте `false`.
  final bool showDialIcon;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final baseStyle = style ??
        tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant) ??
        TextStyle(color: cs.onSurfaceVariant);
    final tapStyle = baseStyle.copyWith(
      color: cs.primary,
      fontWeight: FontWeight.w600,
    );

    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 4,
      runSpacing: 4,
      children: [
        InkWell(
          onTap: () async {
            final ok = await launchPhoneDialer(phone);
            if (!context.mounted) return;
            if (!ok) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Не удалось открыть набор номера'),
                ),
              );
            }
          },
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: EdgeInsets.symmetric(
              vertical: dense ? 2 : 4,
              horizontal: 4,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (showDialIcon) ...[
                  Icon(
                    Icons.phone_in_talk_outlined,
                    size: dense ? 18 : 20,
                    color: cs.primary,
                  ),
                  const SizedBox(width: 6),
                ],
                Text(phone, style: tapStyle),
              ],
            ),
          ),
        ),
        IconButton(
          tooltip: 'Скопировать номер',
          visualDensity:
              dense ? VisualDensity.compact : VisualDensity.standard,
          constraints: dense
              ? const BoxConstraints(minWidth: 32, minHeight: 32)
              : null,
          padding: dense ? EdgeInsets.zero : null,
          icon: Icon(
            Icons.copy_rounded,
            size: dense ? 18 : 22,
            color: cs.onSurfaceVariant,
          ),
          onPressed: () {
            Clipboard.setData(ClipboardData(text: phone));
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Номер скопирован')),
            );
          },
        ),
      ],
    );
  }
}
