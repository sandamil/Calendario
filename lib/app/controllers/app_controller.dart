
import 'dart:io';

import 'package:calendario2/app/modules/ajustes/views/pages/util/notifications/notifications.dart';
import 'package:calendario2/config/util/app_utils.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:mixpanel_flutter/mixpanel_flutter.dart';

import 'package:google_mobile_ads/google_mobile_ads.dart';

late BannerAd bannerAd;
late Mixpanel mixPanel;
final String _adHomeId = Platform.isAndroid
// ? 'ca-app-pub-5849370961147264/3151373239'
// : 'ca-app-pub-3940256099942544/2934735716';
    ? 'ca-app-pub-3940256099942544/6300978111'
    : 'ca-app-pub-3940256099942544/2934735716';

RxBool staticAdHomeLoaded2 = false.obs;

loadBanner() {
  bannerAd = BannerAd(
    adUnitId: _adHomeId,
    size: AdSize.fullBanner,
    request: const AdRequest(),
    listener: BannerAdListener(
      // Called when an ad is successfully received.
      onAdLoaded: (Ad ad) {
         staticAdHomeLoaded2.value = true;
      },
      // Called when an ad request failed.
      onAdFailedToLoad: (Ad ad, LoadAdError error) {
        // Dispose the ad here to free resources.
        ad.dispose();
        print('Ad failed to load: $error');
      },
      // Called when an ad opens an overlay that covers the screen.
      onAdOpened: (Ad ad) => print('Ad opened.'),
      // Called when an ad removes an overlay that covers the screen.
      onAdClosed: (Ad ad) => print('Ad closed.'),
      // Called when an impression occurs on the ad.
      onAdImpression: (Ad ad) => print('Ad impression.'),
    ),
  )..load();
}

class AppController extends GetxController {

  factory AppController() {
    return _instance;
  }
  AppController._internal() {
    logSys('AppCylceService Initialized');
  }

  static final AppController _instance = AppController._internal();


  String appVersion = 'version 1.0.0';
  // DateTime focusDayRx = DateTime.now().toLocal();

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
   initMixpanel();
    super.onReady();
  }

  

  Future<void> getAppVersion() async {
    appVersion = await AppUtils.getAppVersion();
  }



///Ajustes APPVERSION





  Future<void> initMixpanel() async {
    String mixPanelToken = "7393b8c55d34833deaff8da840c887b2";
    mixPanel = await Mixpanel.init(mixPanelToken, trackAutomaticEvents: true);
    var distinctId = await mixPanel.getDistinctId();
    mixPanel.identify(distinctId);
  }










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