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
  static const String _lightThemeKey = 'light';

  /// init get storage services
  static Future<void> init() async {
    _sharedPreferences = await SharedPreferences.getInstance();
  }

  static setStorage(SharedPreferences sharedPreferences) {
    _sharedPreferences = sharedPreferences;
  }


  static void setThemeMode(ThemeMode themeMode) {
    print('=======================  ==========${themeMode.name}');
    _sharedPreferences.setString(_lightThemeKey, themeMode.name);
  }

  /// set theme current type as light theme
  static Future<void> setThemeIsLight(bool lightTheme) {
    // print('setThemeIsLight=======================  ==========${lightTheme}');
    // print('setThemeIsLight=======================  ==========${_lightThemeKey}');
    return _sharedPreferences.setBool(_lightThemeKey, lightTheme);
  }

  /// get if the current theme type is light
  static bool getThemeIsLight() {
    // print('getThemeIsLight=======================  ==========${_lightThemeKey}');
    // print('getThemeIsLight=======================  ==========${_sharedPreferences.getString(_lightThemeKey)}');
    return _sharedPreferences.getString(_lightThemeKey) == _lightThemeKey;

  } // todo set the default theme (true for light, false for dark)

  static ThemeMode get getThemeMode {
    /// the theme mode is stored as string
    final String? themeMode = _sharedPreferences.getString(_lightThemeKey);

    switch (themeMode) {
      case 'dark':
        return ThemeMode.dark;
      case 'system':
        return ThemeMode.system;

      default:
        return ThemeMode.light;
    }
  }





  /// save current locale
  static Future<void> setCurrentLanguage(String languageCode) =>
      _sharedPreferences.setString(_currentLocalKey, languageCode);

  /// get current locale
  static Locale getCurrentLocal(){
      String? langCode = _sharedPreferences.getString(_currentLocalKey);
      // default language is english
      if(langCode == null){
        return LocalizationService.defaultLanguage;
      }
      return LocalizationService.supportedLanguages[langCode]!;
  }



  /// clear all data from shared pref
  static Future<void> clear() async => await _sharedPreferences.clear();

}