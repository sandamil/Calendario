import 'dart:async';
import 'dart:io';

import 'package:calendario2/config/util/app_utils.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';

import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';


const bool kIsWeb = bool.fromEnvironment('dart.library.js_util');
const String navigationActionId = 'id_3';

class AppController extends GetxController {
  String appVersion = 'version 1.0.0';
  final StreamController<ReceivedNotification> didReceiveLocalNotificationStream =
  StreamController<ReceivedNotification>.broadcast();
  final StreamController<String?> selectNotificationStream =
  StreamController<String?>.broadcast();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

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
  void onReady() async {

    await _configureLocalTimeZone();



    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('app_icon');


    /// Note: permissions aren't requested here just to demonstrate that can be
    /// done later
    final DarwinInitializationSettings initializationSettingsDarwin =
    DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
      onDidReceiveLocalNotification:
          (int id, String? title, String? body, String? payload) async {
        didReceiveLocalNotificationStream.add(
          ReceivedNotification(
            id: id,
            title: title,
            body: body,
            payload: payload,
          ),
        );
      },
      // notificationCategories: darwinNotificationCategories,
    );
    final LinuxInitializationSettings initializationSettingsLinux =
    LinuxInitializationSettings(
      defaultActionName: 'Open notification',
      defaultIcon: AssetsLinuxIcon('icons/app_icon.png'),
    );
    final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
      macOS: initializationSettingsDarwin,
      linux: initializationSettingsLinux,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse:
          (NotificationResponse notificationResponse) {
        switch (notificationResponse.notificationResponseType) {
          case NotificationResponseType.selectedNotification:
            selectNotificationStream.add(notificationResponse.payload);
            break;
          case NotificationResponseType.selectedNotificationAction:
            if (notificationResponse.actionId == navigationActionId) {
              selectNotificationStream.add(notificationResponse.payload);
            }
            break;
        }
      },
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    );
    super.onReady();
  }

  void notificationTapBackground(NotificationResponse notificationResponse) {
    // ignore: avoid_print
    print('notification(${notificationResponse.id}) action tapped: '
        '${notificationResponse.actionId} with'
        ' payload: ${notificationResponse.payload}');
    if (notificationResponse.input?.isNotEmpty ?? false) {
      // ignore: avoid_print
      print(
          'notification action tapped with input: ${notificationResponse.input}');
    }
  }

  Future<void> _configureLocalTimeZone() async {
    if (kIsWeb || Platform.isLinux) {
      return;
    }
    tz.initializeTimeZones();
    final String? timeZoneName = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timeZoneName!));
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




class ReceivedNotification {
  ReceivedNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.payload,
  });

  final int id;
  final String? title;
  final String? body;
  final String? payload;
}