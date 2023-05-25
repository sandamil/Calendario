
import 'package:calendario2/app/modules/ajustes/views/pages/util/notifications/notifications.dart';
import 'package:calendario2/config/util/app_utils.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';


class AppController extends GetxController {
  String appVersion = 'version 1.0.0';

  // RxBool isShowLog = true.obs;
  // RxString currentPage = ''.obs;
  // Rx<AppLanguageModel> appLanguage = AppLanguageModel().obs;
  // RxList<AppLanguageModel> appLanguageOptions = <AppLanguageModel>[].obs;



  @override
  void onInit() {
    // initData();
    // getAppVersion();
    // getAppLanguageOptions();
    super.onInit();
  }


  @override
  void onReady() {
   Notifications.instance.init();

    super.onReady();
  }

  

  Future<void> getAppVersion() async {
    appVersion = await AppUtils.getAppVersion();
  }



///Ajustes APPVERSION















  List<Axiss> supportedOrientations = [Axiss.vertical, Axiss.horizontal];

  List<Axiss>? _supportedOrientationsOverride;
  set supportedOrientationsOverride(List<Axiss>? value) {
    if (_supportedOrientationsOverride != value) {
      _supportedOrientationsOverride = value;
      _updateSystemOrientation();
    }
  }

  void _updateSystemOrientation() {
    final axisList = _supportedOrientationsOverride ?? supportedOrientations;
    //debugPrint('updateDeviceOrientation, supportedAxis: $axisList');
    final orientations = <DeviceOrientation>[];
    if (axisList.contains(Axiss.vertical)) {
      orientations.addAll([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
    }
    if (axisList.contains(Axiss.horizontal)) {
      orientations.addAll([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    }
    SystemChrome.setPreferredOrientations(orientations);
  }

  // Future<void> initData() async {
  //   final b = await AppStorage.isContain(key: 'log-button');
  //   isShowLog(b);
  // }





  // Future<void> showLogButton() async {
  //   await AppStorage.write(key: LOG_BUTTON, value: '1');
  //   isShowLog(true);
  // }

  // Future<void> hideLogButton() async {
  //   await AppStorage.delete(key: LOG_BUTTON);
  //   isShowLog(false);
  // }

  // Future<void> getAppLanguageOptions() async {
  //   appLanguageOptions(
  //     RxList.from(appLanguageData.map(AppLanguageModel.fromJson)),
  //   );
  // }
  //
  // Future<void> getAppLanguage() async {
  //   final data = await AppStorage.read(key: APP_LANGUAGE);
  //
  //   if (data.isNotEmpty) {
  //     final value = jsonDecode(data);
  //
  //     appLanguage.value = AppLanguageModel(
  //       language: value['language'],
  //       locale: Locale(value['language_code'], value['country_code']),
  //     );
  //
  //     await Get.updateLocale(
  //       Locale(value['language_code'], value['country_code']),
  //     );
  //   } else {
  //     await Get.updateLocale(const Locale('en', 'US'));
  //   }
  // }
  //
  // Future<void> changeLanguage(AppLanguageModel value) async {
  //   appLanguage.value = value;
  //
  //   final data = {
  //     'language': value.language,
  //     'language_code': value.locale.languageCode,
  //     'country_code': value.locale.countryCode,
  //   };
  //
  //   await AppStorage.write(key: APP_LANGUAGE, value: jsonEncode(data));
  //
  //   await Get.updateLocale(
  //     Locale(value.locale.languageCode, value.locale.countryCode),
  //   );
  // }
}

enum Axiss {
  /// Left and right.
  ///
  /// See also:
  ///
  ///  * [TextDirection], which disambiguates between left-to-right horizontal
  ///    content and right-to-left horizontal content.
  horizontal,

  /// Up and down.
  vertical,
}