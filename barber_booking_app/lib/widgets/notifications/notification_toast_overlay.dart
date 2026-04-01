import 'package:barber_booking_app/providers/notification_providers/notification_toast_controller.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class NotificationToastOverlay extends StatelessWidget {
  const NotificationToastOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<NotificationToastController>(
      builder: (context, ctrl, _) {
        if (ctrl.items.isEmpty) return const SizedBox.shrink();
        return Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (final n in ctrl.items)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Dismissible(
                        key: ValueKey(n.id),
                        direction: DismissDirection.horizontal,
                        onDismissed: (_) => ctrl.dismiss(n.id),
                        background: Container(
                          alignment: Alignment.centerLeft,
                          padding: const EdgeInsets.only(left: 20),
                          color: Colors.red.withValues(alpha: 0.35),
                          child: const Icon(Icons.close),
                        ),
                        secondaryBackground: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          color: Colors.red.withValues(alpha: 0.35),
                          child: const Icon(Icons.close),
                        ),
                        child: Material(
                          elevation: 8,
                          borderRadius: BorderRadius.circular(12),
                          color: Theme.of(context)
                              .colorScheme
                              .surfaceContainerHighest,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                            child: Text(
                              n.text,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
