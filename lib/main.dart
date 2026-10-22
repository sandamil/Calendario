import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'app/components/custom_snackbar.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:get_storage/get_storage.dart';

import 'app/controllers/ads_provider.dart';
import 'app/data/local/my_shared_pref.dart';
import 'app/modules/ajustes/views/pages/util/notifications/notifications.dart';

import 'app/routes/app_router.dart';
import 'config/theme/my_theme.dart';
import 'config/theme/theme_provider.dart';
import 'config/translations/localization_service.dart';
import 'package:intl/date_symbol_data_local.dart';

//
// import 'package:firebase_core/firebase_core.dart';
// import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Future.wait<void>([
    Notifications.instance.init(),
    initMemory(),
  ]);
  // MySharedPref.init();
  // GetStorage.init();

  //  Firebase.initializeApp(
  //   options: DefaultFirebaseOptions.currentPlatform,
  // );
  // Log.init();

  if (!kIsWeb) {
    unawaited(
      initializeMobileAds().then<void>(
        (_) {},
        onError: (Object error, StackTrace stackTrace) {
          debugPrint('[ADS] Error al inicializar Mobile Ads: $error');
        },
      ),
    );
  }

  initializeDateFormatting("es_ES");

  runApp(
    ProviderScope(
      child: buildApp(),
    ),
  );
}

Future<void> initMemory() async {
  await Future.wait<void>([
    MySharedPref.init(),
    GetStorage.init().then<void>((_) {}),
  ]);
  // var status = await Permission.storage.status;
  // if (status.isDenied) {
  //   // You can request multiple permissions at once.
  //   Map<Permission, PermissionStatus> statuses = await [
  //     Permission.storage,
  //     // Permission.camera,
  //   ].request();
  // }
}

Widget buildApp() {
  return ScreenUtilInit(
    designSize: const Size(375, 812),
    minTextAdapt: true,
    splitScreenMode: true,
    useInheritedMediaQuery: true,
    rebuildFactor: (old, data) => true,
    builder: (context, widget) {
      return Consumer(
        builder: (context, ref, _) {
          final themeMode = ref.watch(themeModeProvider);
            final locale = ref.watch(localeProvider);

          return MaterialApp.router(
              scaffoldMessengerKey: CustomSnackBar.messengerKey,
            routerConfig: appRouter,
            title: "Calendario",
            theme: MyTheme.getThemeData(isLight: true),
            darkTheme: MyTheme.getThemeData(isLight: false),
            themeMode: themeMode,
            locale: locale,
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: LocalizationService.supportedLanguages.values,
            debugShowCheckedModeBanner: false,
            builder: (context, child) {
              final mediaQuery = MediaQuery.of(context);
              return MediaQuery(
                data: mediaQuery.copyWith(
                  textScaler: TextScaler.linear(
                    mediaQuery.size.width <= 360 ? .85 : 1,
                  ),
                ),
                child: child ?? const SizedBox.shrink(),
              );
            },
          );
        },
      );
    },
  );
}
