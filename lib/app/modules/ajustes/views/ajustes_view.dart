import 'package:calendario2/config/theme/my_colors.dart';
import 'package:calendario2/config/theme/my_fonts.dart';
import 'package:calendario2/config/util/assets.dart';
import 'package:calendario2/widgets/setting_title_tile.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:get/get.dart';
import 'package:rive/rive.dart';

import '../controllers/ajustes_controller.dart';
import '../../../../widgets/setting_title.dart';

class AjustesView extends GetView<AjustesController> {
  const AjustesView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.home,
            color: PRIMARY_COLOR,
            size: 26.sp,
          ),
          onPressed: () {
            Get.offAllNamed('/home');
          },
        ),
        centerTitle: false,
        elevation: 0.0,
        backgroundColor: Colors.transparent,
        title: Text(
          'Settings'.tr,
          style: CustomTextStyle.appBarTitle(context: context),
        ),
      ),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 10.w),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SettingTitleTile('General'),

              Obx(() {
                return SettingTile(
                    icon: ConstrainedBox(
                      constraints:
                      const BoxConstraints.expand(height: 50, width: 50),
                      child: Rive(
                        artboard: controller.artboard.value!,
                        fit: BoxFit.fill,
                        useArtboardSize: true,
                      ),
                    ),
                    btnText: "Theme".tr,
                    trailing: GestureDetector(
                        child: ConstrainedBox(
                          constraints:
                          const BoxConstraints.expand(height: 40, width: 80),
                          child: Rive(
                            artboard: controller.artboard2.value!,
                            fit: BoxFit.fill,
                            useArtboardSize: true,
                          ),
                        ),
                        onTap: () async {
                          controller.cambioModo();
                        })

                  // CupertinoSwitch(
                  //   value: controller.isDark.value,
                  //   onChanged: (val) async {
                  //     controller.isDark.value = !controller.isDark.value;
                  //     await controller.changeTheme(val);
                  //   },
                  // ),
                );
              }),

              SettingTile(
                  icon: const ImageIcon(AssetImage(MyIcon.languageIcon)),
                  btnText: 'Language'.tr,
                  trailing: Text(controller.selectedLanguage.value.name),
                  onPressed: controller.goToLanguageScreen),
              Divider(
                indent: 15.w,
                endIndent: 15.w,
              ),
              SettingTitleTile("Notificationes".tr),
              SettingTile(
                icon: const ImageIcon(AssetImage(MyIcon.notificationIcon)),
                btnText: "Ajustes alarma".tr,
                //   trailing: KSwitch(),
              ),
              // SettingTile(
              //   icon: const ImageIcon(AssetImage(MyIcon.solIcon)),
              //   btnText: "Ajustes alarma".tr,
              //   //   trailing: KSwitch(),
              // ),
              Divider(
                indent: 15.w,
                endIndent: 15.w,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SettingTitleTile("Version Pro".tr),
                  Padding(
                    padding: EdgeInsets.only(right: 12.w),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size.zero,
                        // Set this
                        padding: const EdgeInsets.all(1),
                        elevation: 10,
                        disabledBackgroundColor: Colors.green,
                        backgroundColor: Colors.green,
                        // background (button) color
                        foregroundColor:
                        Colors.green, // foreground (text) color
                      ),
                      onPressed: () {},
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8.w),
                        child: Text('Obtener version pro', style: TextStyle(
                            color: MyColors.textButtom),),
                      ),
                    ),
                  )
                ],
              ),
              SettingTile(
                icon: const ImageIcon(AssetImage(MyIcon.candadoIcon)),
                btnText: "Login".tr,
                trailing: const Text(""),
                onPressed: () {
                  controller.launchGmail();
                  Get.toNamed('/boarding');
                },
              ),
              SettingTile(
                icon: const ImageIcon(AssetImage(MyIcon.candadoIcon)),
                btnText: "Registro".tr,
                trailing: const Text(""),
                onPressed: () {
                  controller.reportProblem();
                },
              ),
              //
              SettingTile(
                icon: const ImageIcon(AssetImage(MyIcon.candadoIcon)),
                btnText: "Exportar Pdf".tr,
                trailing: const Text(""),
                onPressed: () {
                  // controller.showFeedback(context);
                },
              ),
              SettingTile(
                icon: const ImageIcon(AssetImage(MyIcon.candadoIcon)),
                btnText: "Backup".tr,
                trailing: const Text("Online"),
                onPressed: () {
                  controller.launchTwitter();
                },
              ),
              SizedBox(height: 20.h),
              Divider(
                indent: 15.w,
                endIndent: 15.w,
              ),
            ],
          ),
        ),
      ),
    );
  }

}
