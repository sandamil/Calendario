import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'app/bindings/initial_bindings.dart';
import 'app/controllers/ads_provider.dart';
import 'app/data/local/my_shared_pref.dart';
import 'app/modules/ajustes/views/pages/util/notifications/notifications.dart';

import 'app/routes/app_pages.dart';
import 'config/theme/my_theme.dart';
import 'config/translations/localization_service.dart';
import 'package:intl/date_symbol_data_local.dart';

//
// import 'package:firebase_core/firebase_core.dart';
// import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Notifications.instance.init();
  // MySharedPref.init();
  // GetStorage.init();

  //  Firebase.initializeApp(
  //   options: DefaultFirebaseOptions.currentPlatform,
  // );
  // Log.init();

  unawaited(
    initializeMobileAds().then<void>(
      (_) {},
      onError: (Object error, StackTrace stackTrace) {
        debugPrint('[ADS] Error al inicializar Mobile Ads: $error');
      },
    ),
  );

  await initMemory();
  initializeDateFormatting("es_ES");

  runApp(
    ProviderScope(
      child: buildApp(),
    ),
  );
}

Future<void> initMemory() async {
  await MySharedPref.init();
  await GetStorage.init();
  // var status = await Permission.storage.status;
  // if (status.isDenied) {
  //   // You can request multiple permissions at once.
  //   Map<Permission, PermissionStatus> statuses = await [
  //     Permission.storage,
  //     // Permission.camera,
  //   ].request();
  // }
}

buildApp() {
  return ScreenUtilInit(
    designSize: const Size(375, 812),
    minTextAdapt: true,
    splitScreenMode: true,
    useInheritedMediaQuery: true,
    rebuildFactor: (old, data) => true,
    builder: (context, widget) {
      return GetMaterialApp(
        title: "Calendario",
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: LocalizationService.supportedLanguages.values,
        useInheritedMediaQuery: true,
        debugShowCheckedModeBanner: false,
        builder: (context, widget) {
          bool themeIsLight = MySharedPref.getThemeIsLight();
          return Theme(
            data: MyTheme.getThemeData(isLight: themeIsLight),
            child: MediaQuery(
              // prevent font from scalling (some people use big/small device fonts)
              // but we want our app font to still the same and dont get affected
              data: MediaQuery.of(context).copyWith(
                  textScaleFactor:
                      MediaQuery.of(context).size.width <= 360 ? .85 : 1),
              child: widget!,
            ),
          );
        },
        initialRoute: '/inicio', // first screen to show when app is running
        getPages: AppPages.routes, // app screens
        initialBinding: InitialBindings(),
        locale: MySharedPref.getCurrentLocal(), // app language
        translations: LocalizationService
            .getInstance(), // localization services in app (controller app language)
      );
    },
  );
}
