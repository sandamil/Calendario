import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../app/data/local/my_shared_pref.dart';
import 'ar_AR/ar_ar_translation.dart';
import 'en_US/en_us_translation.dart';
import 'es_ES/es_es_translation.dart';

class LocalizationService {
  LocalizationService._();

  static Locale defaultLanguage = supportedLanguages['es']!;

  static final Map<String, Locale> supportedLanguages = {
    'en': const Locale('en', 'US'),
    'ar': const Locale('ar', 'AR'),
    'es': const Locale('es', 'ES'),
  };

  static final Map<String, TextStyle> supportedLanguagesFontsFamilies = {
    'es': GoogleFonts.titilliumWeb(),
    'en': GoogleFonts.titilliumWeb(),
    'ar': GoogleFonts.cairo(),
  };

  static bool isLanguageSupported(String languageCode) =>
      supportedLanguages.containsKey(languageCode);

  static bool isItEnglish() =>
      MySharedPref.getCurrentLocal().languageCode.toLowerCase().contains('en');

  static Locale getCurrentLocal() => MySharedPref.getCurrentLocal();

  /// Traduce un texto español usando los diccionarios existentes.
  /// Si falta una traducción, conserva el texto original.
  static String translate(String source, Locale locale) {
    final languageCode = locale.languageCode;
    final Map<String, String> target;

    switch (languageCode) {
      case 'en':
        target = enUs;
        break;
      case 'ar':
        target = arAR;
        break;
      case 'es':
      default:
        target = esES;
    }

    for (final entry in esES.entries) {
      if (entry.value == source) {
        return target[entry.key] ?? source;
      }
    }

    return source;
  }
}

final localeProvider = NotifierProvider<LocaleNotifier, Locale>(
  LocaleNotifier.new,
);

class LocaleNotifier extends Notifier<Locale> {
  @override
  Locale build() => MySharedPref.getCurrentLocal();

  Future<void> changeLanguage(String languageCode) async {
    if (!LocalizationService.isLanguageSupported(languageCode)) {
      throw ArgumentError.value(languageCode, 'languageCode', 'Idioma no soportado');
    }

    final newLocale = LocalizationService.supportedLanguages[languageCode]!;

    await MySharedPref.setCurrentLanguage(languageCode);
    state = newLocale;
  }
}
