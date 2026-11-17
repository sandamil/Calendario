import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import 'app/components/custom_snackbar.dart';

import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:get_storage/get_storage.dart';

import 'app/controllers/ads_service.dart';
import 'app/data/local/backup_service.dart';
import 'app/data/local/calendarDatabase.dart';
import 'app/data/local/my_shared_pref.dart';
import 'app/data/local/recovery_manifest_store.dart';
import 'app/data/local/recovery_service.dart';
import 'app/data/local/taskDatabase.dart';
import 'app/bootstrap/bootstrap_root.dart';
import 'app/bootstrap/startup_sequence.dart';
import 'app/modules/recovery/recovery_entry_screen.dart';
import 'app/modules/ajustes/views/pages/util/notifications/notifications.dart';
import 'app/modules/notas/services/notificaciones_service.dart';
import 'app/modules/sync/services/supabase_sync_service.dart';

import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

import 'app/routes/app_router.dart';
import 'config/theme/my_theme.dart';
import 'config/theme/theme_provider.dart';
import 'config/translations/localization_service.dart';
import 'firebase_options.dart';
import 'config/supabase_config.dart';

import 'package:intl/date_symbol_data_local.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    BootstrapRoot(
      initialize: _initializeBeforeApp,
      applicationBuilder: () => ProviderScope(child: buildApp()),
      recoveryBuilder: _buildStartupFailure,
    ),
  );
}

Future<RecoveryService> _createRecoveryService() async {
  final manifestStore = await createRecoveryManifestStore();
  final factory = kIsWeb ? databaseFactoryFfiWeb : databaseFactory;
  return RecoveryService(
    databaseFactory: factory,
    pathResolver: () async => RecoveryDatabasePaths(
      calendarTargetPath: await CalendarioDB().databasePath(),
      notesTargetPath: await NotasDB().databasePath(),
    ),
    manifestStore: manifestStore,
  );
}

Future<void> _initializeBeforeApp() async {
  await runPreProviderStartup(
    replayExternalManifest: () async {
      final recovery = await _createRecoveryService();
      await recovery.replayPendingManifest();
    },
    recoverLegacyJournal: AppBackupService.recoverPendingRestore,
    initializeNotifications: () async {
      await Future.wait<void>([
        Notifications.instance.init(),
        NotificacionesService.instance.inicializar(),
      ]);
    },
    initializeMemory: initMemory,
    initializeDateFormatting: () async {
      await initializeDateFormatting('es_ES');
    },
  );

  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }
  } catch (error, stackTrace) {
    debugPrint(
      '[FIREBASE] Sin servicios cloud; se mantiene el modo local: $error',
    );
    debugPrintStack(stackTrace: stackTrace);
  }

  try {
    await Supabase.initialize(
      url: SupabaseConfig.url,
      publishableKey: SupabaseConfig.publishableKey,
    );
    supabaseInitialized = true;
    unawaited(
      SupabaseSyncService.instance.startIfLinked().then<void>(
        (_) {},
        onError: (Object error, StackTrace stackTrace) {
          debugPrint(
            '[SUPABASE SYNC] No se pudo reanudar la sincronización: $error',
          );
          debugPrintStack(stackTrace: stackTrace);
        },
      ),
    );
  } catch (error, stackTrace) {
    supabaseInitialized = false;
    debugPrint(
      '[SUPABASE] Sin sincronización cloud; se mantiene el modo local: $error',
    );
    debugPrintStack(stackTrace: stackTrace);
  }

  if (!kIsWeb) {
    unawaited(
      CalendarioAds.prepare().then<void>(
        (_) async {},
        onError: (Object error, StackTrace stackTrace) {
          debugPrint('[ADS] Error al inicializar Mobile Ads: $error');
        },
      ),
    );
  }
}

Widget _buildStartupFailure(
  BootstrapFailure failure,
  Future<void> Function() retry,
) => RecoveryEntryScreen(failure: failure, onRetry: retry);

Future<void> initMemory() async {
  await Future.wait<void>([
    MySharedPref.init(),
    GetStorage.init().then<void>((_) {}),
  ]);
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
            title: 'Calendario',
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
