import 'package:calendario2/app/controllers/ads_provider.dart';
import 'dart:io';

import 'package:calendario2/app/components/custom_dialog.dart';
import 'package:calendario2/app/modules/ajustes/providers/ajustes_provider.dart';
import 'package:calendario2/app/modules/ajustes/views/pages/backup_screen.dart';
import 'package:calendario2/app/modules/ajustes/views/pages/language_screen.dart';
import 'package:calendario2/config/theme/my_colors.dart';
import 'package:calendario2/config/theme/theme_provider.dart';
import 'package:calendario2/config/theme/my_fonts.dart';
import 'package:calendario2/config/util/assets.dart';
import 'package:calendario2/widgets/setting_title.dart';
import 'package:calendario2/widgets/setting_title_tile.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class AjustesView extends ConsumerWidget {
  AjustesView({Key? key}) : super(key: key);

  Future<bool> _goHome(BuildContext context, WidgetRef ref) async {
    ref.read(adsProvider.notifier).ensureHomeBanner();
    context.go('/home');
    return false;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(ajustesProvider);
    final isDark = ref.watch(themeModeProvider) == ThemeMode.dark;
    final notifier = ref.read(ajustesProvider.notifier);

    return WillPopScope(
      onWillPop: () async {
        if (Platform.isAndroid) {
          return _goHome(context, ref);
        }
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.home, color: PRIMARY_COLOR, size: 26.sp),
            onPressed: () => _goHome(context, ref),
          ),
          centerTitle: false,
          elevation: 0,
          backgroundColor: Colors.transparent,
          title: Text(
            'Ajustes'.tr,
            style: CustomTextStyle.appBarTitle(context: context),
          ),
        ),
        body: Container(
          padding: EdgeInsets.symmetric(horizontal: 10.w),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SettingTitleTile('General'.tr),
                SettingTile(
                  icon: ConstrainedBox(
                    constraints: const BoxConstraints.expand(
                      height: 50,
                      width: 50,
                    ),
                    child: Icon(
                      isDark ? Icons.dark_mode : Icons.light_mode,
                      size: 32,
                    ),
                  ),
                  btnText: 'Tema'.tr,
                  trailing: GestureDetector(
                    onTap: notifier.cambioModo,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints.expand(
                        height: 40,
                        width: 80,
                      ),
                      child: Icon(
                        isDark ? Icons.toggle_on : Icons.toggle_off,
                        size: 40,
                      ),
                    ),
                  ),
                ),
                SettingTile(
                  icon: const Icon(Icons.backup, size: 20),
                  btnText: 'Backup'.tr,
                  onPressed: () {
                    context.push('/backup');
                  },
                ),
                Divider(indent: 15.w, endIndent: 15.w),
                SettingTitleTile('Sobre Nosotros'.tr),
                SettingTile(
                  icon: const ImageIcon(AssetImage(MyIcon.notificationIcon)),
                  btnText: 'Información App'.tr,
                  onPressed: () => context.push('/about'),
                ),
                Divider(indent: 15.w, endIndent: 15.w),
                const SettingTitleTile('Proximamente...'),
                SettingTile(
                  btnText: 'rate_this_app',
                  trailing: const Padding(
                    padding: EdgeInsets.all(8),
                  ),
                  onPressed: () {},
                ),
                SettingTile(
                  icon: const ImageIcon(AssetImage(MyIcon.languageIcon)),
                  btnText: 'Idioma'.tr,
                  trailing: Text(settings.selectedLanguage.name),
                  onPressed: () {
                    context.push('/idioma');
                  },
                ),
                SettingTile(
                  icon: const ImageIcon(AssetImage(MyIcon.notificationIcon)),
                  btnText: 'Ajustes alarma'.tr,
                  onPressed: () {
                    MyCustomDialog.showPopUpInfo(
                      context: context,
                      description:
                          'En próximas actualizaciones estará disponible'.tr,
                      title: 'Pronto Disponible'.tr,
                    );
                  },
                ),
                SettingTile(
                  icon: const ImageIcon(AssetImage(MyIcon.candadoIcon)),
                  btnText: 'Login'.tr,
                  trailing: const Text(''),
                  onPressed: () => context.push('/boarding'),
                ),
                SettingTile(
                  icon: const ImageIcon(AssetImage(MyIcon.candadoIcon)),
                  btnText: 'Registro'.tr,
                  trailing: const Text(''),
                  onPressed: () {},
                ),
                SettingTile(
                  icon: const ImageIcon(AssetImage(MyIcon.candadoIcon)),
                  btnText: 'Exportar Pdf'.tr,
                  trailing: const Text(''),
                  onPressed: () {},
                ),
                SizedBox(height: 20.h),
                Divider(indent: 15.w, endIndent: 15.w),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
