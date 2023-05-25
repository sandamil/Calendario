import 'dart:developer';

import 'package:calendario2/app/data/local/calendarDatabase.dart';
import 'package:calendario2/app/data/local/my_shared_pref.dart';
import 'package:calendario2/app/data/model/language.dart';
import 'package:calendario2/app/modules/ajustes/views/pages/util/connector_parameter.dart';
import 'package:calendario2/app/modules/ajustes/views/pages/language_screen.dart';
import 'package:calendario2/config/theme/my_theme.dart';
import 'package:calendario2/config/translations/localization_service.dart';
import 'package:calendario2/config/util/constant.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:rive/rive.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../config/util/backup_restore.dart';
import '../../../../debug/log/log.dart';
import '../../../data/local/taskDatabase.dart';
import '../views/pages/backup_screen.dart';
import '../views/pages/util/dio_connector.dart';
import '../views/widgets/alarm_settings.dart';

class AjustesController extends GetxController {


  RxBool isDark = true.obs;

  final List<Language> languages = <Language>[];
  late Rx<Language> selectedLanguage;

  late RiveAnimationController? _controller;
  late RiveAnimationController? _controller2;

  final artboard = Rxn<RuntimeArtboard>();
  final artboard2 = Rxn<RuntimeArtboard>();



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
    artboard.value = RuntimeArtboard();
    rootBundle.load(ConstantData.lightdark_theme).then((data) async {
      final file = RiveFile.import(data);
      final _artboard = file.mainArtboard as RuntimeArtboard;
      _artboard.addController(_controller = (!isDark.value)
          ? SimpleAnimation('to light')
          : SimpleAnimation('to dark'));
      artboard.value = _artboard;
    });

    artboard2.value = RuntimeArtboard();
    rootBundle.load(ConstantData.darklightswitch).then((data) async {
      final file = RiveFile.import(data);
      final _artboard2 = file.mainArtboard as RuntimeArtboard;
      _artboard2.addController(_controller2 = (!isDark.value)
          ? SimpleAnimation('ltr')
          : SimpleAnimation('rtl'));
      artboard2.value = _artboard2;
    });

    super.onInit();
  }



  Future<void> cambioModo() async {
    isDark.value = !isDark.value;
    await changeTheme(isDark.value);
  }

  Future<void> changeTheme(bool value) async {
    if (value) {
      artboard.value?.removeController(_controller!);
      artboard.value?.addController(_controller = SimpleAnimation('to dark'));
      artboard2.value?.removeController(_controller2!);
      artboard2.value?.addController(_controller2 = SimpleAnimation('rtl'));
      Get.snackbar("Tema oscuro", "Modo oscuro activado",
          colorText: Colors.white, snackPosition: SnackPosition.BOTTOM);
      update();
      isDark.value = true;
      MyTheme.changeTheme();
    } else {
      artboard.value?.removeController(_controller!);
      artboard.value?.addController(_controller = SimpleAnimation('to light'));
      artboard2.value?.removeController(_controller2!);
      artboard2.value?.addController(_controller2 = SimpleAnimation('ltr'));
      Get.snackbar("Tema claro", "Modo brillante activado",
          colorText: Colors.white, snackPosition: SnackPosition.BOTTOM);
      update();
      isDark.value = false;
      MyTheme.changeTheme();
    }
  }

  void backup() {
    Get.to(
          () => const BackupScreen(),
      transition: Transition.fadeIn,
      duration: const Duration(milliseconds: 100),
    );
  }



  void goToLanguageScreen() {
    Get.to(
      () => const LanguageScreen(),
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
      Language(name: 'Español'.tr, languageCode: 'es'),
      Language(name: 'Arabe'.tr, languageCode: 'ar'),
      Language(name: 'English'.tr, languageCode: 'en'),
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
    }
  }

  void launchTwitter() async {
    const String url = 'https://www.twitter.com/@ajatsoft';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
    }
  }



  void editarAlarmas() {
    // Get.to(AlarmSettingsScreen());
  }




  loadAlarms() async {
    // alarms.value = Alarm.getAlarms();
    // alarms.sort((a, b) => a.dateTime.isBefore(b.dateTime) ? 0 : 1);
    // searchIdAlarma();
    update();
  }

  Future<String> getDataByGet(ConnectorParameter parameter) async {
    try {
      String result = await DioConnector.instance.getDataByGet(parameter);
      return result;
    } catch (e) {
      rethrow;
    }
  }


  ///=============Backup==============
  void backupNotasDb() {
    NotasDB databaseRepository = NotasDB();
    print('backupNotasDb');
    backupDb(databaseRepository);
  }

  void restoreNotasDb() {
    NotasDB databaseRepository = NotasDB();
    print('restoreNotasDb');
    restaurarDb(databaseRepository);
  }

  void backupCalendarioDb() {
    CalendarioDB databaseRepository = CalendarioDB();
    print('backupCalendarioDb');
    backupDb(databaseRepository);
  }

  void restoreCalendarioDb() {
    CalendarioDB databaseRepository = CalendarioDB();
    print('restoreCalendarioDb');
    restaurarDb(databaseRepository);
  }


}
