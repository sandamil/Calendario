// // ignore_for_file: import_of_legacy_library_into_null_safe
//
//
// class APPVersion {
//   static void initAndCheck() async {
//     final versionConfig = await RemoteConfigUtil.getVersionConfig();
//
//     if (!versionConfig.isFocusUpdate) {
//       if (!LocalStorage.instance.autoCheckAppUpdate ||
//           !LocalStorage.instance.getFirstUse(LocalStorage.appCheckUpdate) ||
//           LocalStorage.instance.getAccount().isEmpty) return;
//     }
//
//     LocalStorage.instance.setAlreadyUse(LocalStorage.appCheckUpdate);
//
//     Log.d("Start check update");
//     await AppUpdate.checkUpdate(versionConfig: versionConfig);
//
//     checkIFAPPUpdate();
//   }
//
//   static Future<bool> checkShouldUpdate() {
//     return AppUpdate.checkUpdate();
//   }
//
//   static Future<void> checkIFAPPUpdate() async {
//     final version = await AppUpdate.getAppVersion();
//     final preVersion = LocalStorage.instance.getVersion();
//     Log.d(" preVersion: $preVersion \n version: $version");
//
//     if (preVersion != version) {
//       await LocalStorage.instance.setVersion(version);
//     }
//   }
// }
