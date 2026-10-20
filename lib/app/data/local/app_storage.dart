import 'package:get_storage/get_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppStorage {
  static Future<void> write({
    required String key,
    required String value,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }

  static Future<String> read({required String key}) async {
    final prefs = await SharedPreferences.getInstance();

    if (prefs.containsKey(key)) {
      return prefs.getString(key) ?? '';
    }

    // Migrar el valor antiguo si existe en instalaciones anteriores.
    final oldValue = GetStorage().read(key);
    if (oldValue is String) {
      await prefs.setString(key, oldValue);
      await GetStorage().remove(key);
      return oldValue;
    }

    return '';
  }
}
