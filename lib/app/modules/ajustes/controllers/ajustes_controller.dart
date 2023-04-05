import 'dart:developer';

import 'package:calendario2/app/data/local/my_shared_pref.dart';
import 'package:calendario2/app/data/model/language.dart';
import 'package:calendario2/app/modules/ajustes/views/widgets/language_screen.dart';
import 'package:calendario2/config/theme/my_theme.dart';
import 'package:calendario2/config/translations/localization_service.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';


class AjustesController extends GetxController {
  RxBool isDark = true.obs;

  final List<Language> languages = <Language>[];
  late Rx<Language> selectedLanguage;

  @override
  void onInit() {
    loadShippingTypes();
    final currentLanguageCode = MySharedPref
        .getCurrentLocal()
        .languageCode;
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

  Future<void> changeTheme(bool value) async {
    if (value) {
      isDark.value = true;
      MyTheme.changeTheme();
    } else {
      isDark.value = false;
      MyTheme.changeTheme();
    }
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

  // launch url
  void launchGmail() async {
    final Uri params = Uri(
      scheme: 'mailto',
      path: 'ajatsoft@gmail.com',
      query: 'subject= Sugerencia para app Calendario 2.0 = ',
    );
    String url = params.toString();
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      print('Could not launch gmail');
    }
  }

  //Report a problem
  void reportProblem() async {
    final Uri params = Uri(
        scheme: 'mailto',
        path: 'ajatsoft@gmail.com',
        query: 'subject=Reportando un problema en App Calendario 2.0= ');
    String url = params.toString();
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      print('Could not launch gmail');
    }
  }

  void launchTwitter() async {
    final String url = 'https://www.twitter.com/@ajatsoft';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      print('Could not launch twitter');
    }
  }

  // void showFeedback(context) {
  //   BetterFeedback.of(context).show((UserFeedback feedback) {
  //     print(feedback.text);
  //   });
  // }
}
