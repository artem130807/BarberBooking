import 'package:barber_booking_app/models/notification_models/app_notification.dart';
import 'package:flutter/foundation.dart';

class NotificationToastController extends ChangeNotifier {
  final List<AppNotification> _items = [];

  List<AppNotification> get items => List.unmodifiable(_items);

  void push(String text) {
    final id =
        '${DateTime.now().microsecondsSinceEpoch}_${text.hashCode}';
    _items.insert(
      0,
      AppNotification(
        id: id,
        text: text,
        createdAt: DateTime.now(),
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
