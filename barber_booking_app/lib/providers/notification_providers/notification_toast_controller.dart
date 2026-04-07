import 'package:barber_booking_app/models/notification_models/app_notification.dart';
import 'package:flutter/foundation.dart';

class NotificationToastController extends ChangeNotifier {
  final List<AppNotification> _items = [];

  List<AppNotification> get items => List.unmodifiable(_items);

  void push(
    String text, {
    String? subtitle,
    DateTime? createdAt,
    String? stableId,
  }) {
    final id = stableId != null && stableId.isNotEmpty
        ? 'srv_${stableId}_${DateTime.now().microsecondsSinceEpoch}'
        : '${DateTime.now().microsecondsSinceEpoch}_${text.hashCode}';
    _items.insert(
      0,
      AppNotification(
        id: id,
        text: text,
        subtitle: subtitle,
        createdAt: createdAt ?? DateTime.now(),
      ),
    );
    if (_items.length > 6) {
      _items.removeRange(6, _items.length);
    }
    notifyListeners();
  }

  void dismiss(String id) {
    _items.removeWhere((e) => e.id == id);
    notifyListeners();
  }
}
