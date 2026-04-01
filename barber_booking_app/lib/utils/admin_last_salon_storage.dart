import 'package:shared_preferences/shared_preferences.dart';

class AdminLastSalonStorage {
  static const _key = 'admin_last_salon_id';

  static Future<String?> read() async {
    final p = await SharedPreferences.getInstance();
    return p.getString(_key);
  }

  static Future<void> write(String? id) async {
    final p = await SharedPreferences.getInstance();
    if (id == null || id.isEmpty) {
      await p.remove(_key);
    } else {
      await p.setString(_key, id);
    }
  }

  static Future<void> clear() => write(null);
}
