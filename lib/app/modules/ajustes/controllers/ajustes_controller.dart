import 'dart:developer';

import 'package:calendario2/app/data/local/my_shared_pref.dart';
import 'package:calendario2/app/data/model/language.dart';
import 'package:calendario2/app/modules/ajustes/views/widgets/language_screen.dart';
import 'package:calendario2/config/theme/my_theme.dart';
import 'package:calendario2/config/translations/localization_service.dart';
import 'package:calendario2/config/util/constant.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:get/get.dart';
import 'package:rive/rive.dart';
import 'package:url_launcher/url_launcher.dart';

class AjustesController extends GetxController {
  RxBool isDark = true.obs;

  final List<Language> languages = <Language>[];
  late Rx<Language> selectedLanguage;

  late RiveAnimationController? _controller;
  late RiveAnimationController? _controller2;
  late RuntimeArtboard artboard;
  late RuntimeArtboard artboard2;

  // var islight = true;
  // var enable = true;

  @override
  void onInit() {
    loadShippingTypes();
    final currentLanguageCode = MySharedPref.getCurrentLocal().languageCode;
    log('curent language code: $currentLanguageCode');
    selectedLanguage = languages
        .firstWhere((element) => element.languageCode == currentLanguageCode)
        .obs;

    if (Get.isDarkMode) {
      isDark.value = true;
    }  else {
      isDark.value = false;
    }
    artboard = RuntimeArtboard();
    rootBundle.load(ConstantData.lightdark_theme).then((data) async {
      final file = RiveFile.import(data);
      final _artboard = file.mainArtboard as RuntimeArtboard;
      _artboard.addController(_controller = (!isDark.value)
          ? SimpleAnimation('to light')
          : SimpleAnimation('to dark'));
      artboard = _artboard;
    });

    artboard2 = RuntimeArtboard();
    rootBundle.load(ConstantData.darklightswitch).then((data) async {
      final file = RiveFile.import(data);
      final _artboard2 = file.mainArtboard as RuntimeArtboard;
      _artboard2.addController(_controller2 = (!isDark.value)
          ? SimpleAnimation('ltr')
          : SimpleAnimation('rtl'));
      artboard2 = _artboard2;
    });

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

  Future<void> cambioModo() async {
    isDark.value = !isDark.value;
    await changeTheme(isDark.value);
  }

  Future<void> changeTheme(bool value) async {
    if (value) {
      artboard.removeController(_controller!);
      artboard.addController(_controller = SimpleAnimation('to dark'));
      artboard2.removeController(_controller2!);
      artboard2.addController(_controller2 = SimpleAnimation('rtl'));
      Get.snackbar("Tema oscuro", "Modo oscuro activado",
          colorText: Colors.white, snackPosition: SnackPosition.BOTTOM);
      update();
      isDark.value = true;
      MyTheme.changeTheme();
    } else {
      artboard.removeController(_controller!);
      artboard.addController(_controller = SimpleAnimation('to light'));
      artboard2.removeController(_controller2!);
      artboard2.addController(_controller2 = SimpleAnimation('ltr'));
      Get.snackbar("Tema claro", "Modo brillante activado",
          colorText: Colors.white, snackPosition: SnackPosition.BOTTOM);
      update();
      isDark.value = false;
      MyTheme.changeTheme();
    }
  }

  void goToLanguageScreen() {
    Get.to(() => LanguageScreen(),
      transition: Transition.fadeIn,
      duration: const Duration(milliseconds: 100),
    );
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

}
