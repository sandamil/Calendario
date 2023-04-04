import 'dart:developer';

import 'package:calendario2/app/data/local/my_shared_pref.dart';
import 'package:calendario2/app/data/model/language.dart';
import 'package:calendario2/app/modules/ajustes/views/widgets/language_screen.dart';
import 'package:calendario2/config/theme/my_theme.dart';
import 'package:calendario2/config/translations/localization_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AjustesController extends GetxController {
  String image = 'assets/3.png';
  String name = 'Jose Manuel';
  String number = '722642022';

  final List<Language> languages = <Language>[];
  late Rx<Language> selectedLanguage;


  @override
  void onInit() {
    loadShippingTypes();
    final currentLanguageCode = MySharedPref.getCurrentLocal().languageCode;
    log('curent language code: $currentLanguageCode');
    selectedLanguage = languages
        .firstWhere((element) => element.languageCode == currentLanguageCode)
        .obs;
    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }


  void setThemeMode(ThemeMode themeMode) {
    MyTheme.changeTheme(themeMode);
  }

  void goToLanguageScreen() {
    Get.to(LanguageScreen());
  }

  setSelectedShippingTypeIndex(String languageCode) {
    selectedLanguage.value =
        languages.firstWhere((l) => l.languageCode == languageCode);
    LocalizationService.changeLanguage(languageCode);
  }

  void onLanguageTilePressed(String languageCode) {
    log('selected language code: $languageCode');
    setSelectedShippingTypeIndex(languageCode);
  }

  void loadShippingTypes() {
    final loadded = getSupportedLanguagesService();
    languages.addAll(loadded);
  }

  List<Language> getSupportedLanguagesService() {
    return [
      Language(name: 'Español', languageCode: 'es'),
      Language(name: 'Arabic', languageCode: 'ar'),
      Language(name: 'English', languageCode: 'en'),
    ];
  }

}
