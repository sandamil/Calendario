import 'package:get_storage/get_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppStorage {
  static Future<void> write({
    required String key,
    required String value,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
    // Mantener sincronizado el almacén antiguo durante la transición.
    await GetStorage().write(key, value);
  }

  static Future<String> read({required String key}) async {
    final prefs = await SharedPreferences.getInstance();

    if (prefs.containsKey(key)) {
      return prefs.getString(key) ?? '';
    }

    // Compatibilidad con datos creados por versiones anteriores.
    final oldValue = GetStorage().read(key);
    if (oldValue is String) {
      await prefs.setString(key, oldValue);
      return oldValue;
    }

    return '';
  }

  static Future<void> delete({required String key}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(key);
    await GetStorage().remove(key);
  }

  static Future<bool> isContain({required String key}) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(key) || GetStorage().hasData(key);
  }

  static Future<void> setBool() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('bool', true);
    await GetStorage().write('bool', true);
  }

  static bool? hasBool() {
    final prefsValue = GetStorage().read('bool');
    return prefsValue is bool ? prefsValue : null;
  }
}
