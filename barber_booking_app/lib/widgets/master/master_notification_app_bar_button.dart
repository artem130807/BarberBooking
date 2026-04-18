import 'package:barber_booking_app/providers/auth_providers/auth_provider.dart';
import 'package:barber_booking_app/providers/message_providers/get_count_messages_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MasterNotificationAppBarButton extends StatelessWidget {
  const MasterNotificationAppBarButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<GetCountMessagesProvider>(
      builder: (context, countProv, _) {
        return Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            IconButton(
              tooltip: 'Уведомления',
              icon: const Icon(Icons.notifications_outlined),
              onPressed: () async {
                await Navigator.pushNamed(context, '/master_notifications');
                if (!context.mounted) return;
                final token = context.read<AuthProvider>().token;
                await context.read<GetCountMessagesProvider>().loadCount();
              },
            ),
            if (countProv.count > 0)
              Positioned(
                right: 6,
                top: 6,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  constraints: const BoxConstraints(minWidth: 18, minHeight: 16),
                  child: Text(
                    countProv.count > 99 ? '99+' : '${countProv.count}',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
