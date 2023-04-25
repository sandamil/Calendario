import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../config/translations/localization_service.dart';

class MySharedPref {
  // prevent making instance
  MySharedPref._();

  // get storage
  static late SharedPreferences _sharedPreferences;

  // STORING KEYS
  static const String _currentLocalKey = 'current_local';
  static const String _lightThemeKey = 'is_theme_light';

  /// init get storage services
  static Future<void> init() async {
    _sharedPreferences = await SharedPreferences.getInstance();
  }

  static setStorage(SharedPreferences sharedPreferences) {
    _sharedPreferences = sharedPreferences;
  }

  /// set theme current type as light theme
  static Future<void> setThemeIsLight(bool lightTheme) =>
      _sharedPreferences.setBool(_lightThemeKey, lightTheme);

  /// get if the current theme type is light
  static bool getThemeIsLight() =>
      _sharedPreferences.getBool(_lightThemeKey) ??
      false; // set the default theme (true for light, false for dark)

  /// save current locale
  static Future<void> setCurrentLanguage(String languageCode) =>
      _sharedPreferences.setString(_currentLocalKey, languageCode);

  /// get current locale
  static Locale getCurrentLocal() {
    String? langCode = _sharedPreferences.getString(_currentLocalKey);
    // default language is english
    if (langCode == null) {
      return LocalizationService.defaultLanguage;
      }
      return LocalizationService.supportedLanguages[langCode]!;
  }

  static Future<void> setTutoHomeFirst(bool first) =>
      _sharedPreferences.setBool('tutoHomeFirst', first);

  static bool getTutoHomeFirst() =>
      _sharedPreferences.getBool("tutoHomeFirst") ?? false;

  static Future<void> setTutoTaskFirst(bool first) =>
      _sharedPreferences.setBool('tutoTask', first);

  static bool getTutoTaskFirst() =>
      _sharedPreferences.getBool("tutoTask") ?? false;

  static Future<void> setTutoAddTaskFirst(bool first) =>
      _sharedPreferences.setBool('tutoAddTask', first);

  static bool getTutoAddTaskFirst() =>
      _sharedPreferences.getBool("tutoAddTask") ?? false;

  static Future<void> setTutoCuadranteFirst(bool first) =>
      _sharedPreferences.setBool('tutoCuadrante', first);

  static bool getTutoCuadranteFirst() =>
      _sharedPreferences.getBool("tutoCuadrante") ?? false;









  /// clear all data from shared pref
  static Future<void> clear() async => await _sharedPreferences.clear();

}