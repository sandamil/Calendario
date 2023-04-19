import 'dart:developer';
import 'dart:io';

import 'package:calendario2/config/translations/localization_service.dart';
import 'package:calendario2/config/util/constant.dart';
import 'package:calendario2/config/util/assets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:get/get.dart';
import 'package:rive/rive.dart';

import '../controllers/ajustes_controller.dart';
import 'widgets/setting_title.dart';

class AjustesView extends GetView<AjustesController> {
  const AjustesView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Settings'.tr,
          style: Theme.of(context).textTheme.headlineLarge,
        ),
        elevation: 0,
        centerTitle: true,
      ),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 10.w),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildTitle('General'),

              SettingTile(
                  icon: ConstrainedBox(
                    constraints:
                        const BoxConstraints.expand(height: 50, width: 50),
                    child: Rive(
                      artboard: controller.artboard,
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
                          artboard: controller.artboard2,
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
                  ),

              SettingTile(
                  icon: const ImageIcon(AssetImage(MyIcon.languageIcon)),
                  btnText: 'Language'.tr,
                  trailing: Text(controller.selectedLanguage.value.name),
                  onPressed: controller.goToLanguageScreen),
              buildTitle("Notificationes".tr),
              SettingTile(
                icon: const ImageIcon(AssetImage(MyIcon.notificationIcon)),
                btnText: "Notificaciones".tr,
                //   trailing: KSwitch(),
              ),
              SettingTile(
                icon: const ImageIcon(AssetImage(MyIcon.solIcon)),
                btnText: "Ajustes alarma".tr,
                //   trailing: KSwitch(),
              ),
              buildTitle("Otros ajustes".tr),
              SettingTile(
                icon: const ImageIcon(AssetImage(MyIcon.solIcon)),
                btnText: "onboarding".tr,
                trailing: const Text(""),
                onPressed: () {
                  controller.launchGmail();
                  Get.toNamed('/boarding');
                },
              ),
              SettingTile(
                icon: const ImageIcon(AssetImage(MyIcon.solIcon)),
                btnText: "Errores".tr,
                trailing: const Text(""),
                onPressed: () {
                  controller.reportProblem();
                },
              ),
              //
              SettingTile(
                icon: const ImageIcon(AssetImage(MyIcon.solIcon)),
                btnText: "FeedBack".tr,
                trailing: Text(""),
                onPressed: () {
                  // controller.showFeedback(context);
                },
              ),
              SettingTile(
                icon: const ImageIcon(AssetImage(MyIcon.solIcon)),
                btnText: "Twitter".tr,
                trailing: const Text(""),
                onPressed: () {
                  controller.launchTwitter();
                },
              ),
              SizedBox(height: 20.h)
              // Divider(
              //   indent: 15.w,
              //   endIndent: 15.w,
              // ),
              // Expanded(
              //   child: ListView(
              //     children: [
              //       ListTile(
              //         // onTap: controller.goToEditProfile,
              //         // leading: ImageIcon(
              //         //   const AssetImage('assets/images/iconos/profile_icon_64.png'),
              //         //   color: Theme.of(context).iconTheme.color,
              //         //   size: 28.sp,
              //         // ),
              //         title: Text('Edit Profile'),
              //         trailing: Icon(
              //           Icons.arrow_forward_ios_rounded,
              //           color: Theme
              //               .of(context)
              //               .iconTheme
              //               .color,
              //           size: 20.sp,
              //         ),
              //       ),
              //       ListTile(
              //         // onTap: controller.goToShippingAddresses,
              //         // leading: ImageIcon(
              //         //   const AssetImage('assets/images/iconos/location_icon_64.png'),
              //         //   color: Theme.of(context).iconTheme.color,
              //         //   size: 28.sp,
              //         // ),
              //         title: Text('Address'.tr),
              //         trailing: Icon(
              //           Icons.arrow_forward_ios_rounded,
              //           color: Theme
              //               .of(context)
              //               .iconTheme
              //               .color,
              //           size: 20.sp,
              //         ),
              //       ),
              //       ListTile(
              //         onTap: () {},
              //         // leading: ImageIcon(
              //         //   const AssetImage('assets/images/iconos/notification_icon_64.png'),
              //         //   color: Theme.of(context).iconTheme.color,
              //         //   size: 28.sp,
              //         // ),
              //         title: Text('Notification'.tr),
              //         trailing: Icon(
              //           Icons.arrow_forward_ios_rounded,
              //           color: Theme
              //               .of(context)
              //               .iconTheme
              //               .color,
              //           size: 20.sp,
              //         ),
              //       ),
              //       ListTile(
              //         onTap: controller.goToLanguageScreen,
              //         leading: ImageIcon(
              //           const AssetImage(MyIcon.languageIcon),
              //           color: Theme
              //               .of(context)
              //               .iconTheme
              //               .color,
              //           size: 28.sp,
              //         ),
              //         title: Text('Language'.tr),
              //         trailing: Icon(
              //           Icons.arrow_forward_ios_rounded,
              //           color: Theme
              //               .of(context)
              //               .iconTheme
              //               .color,
              //           size: 20.sp,
              //         ),
              //       ),
              //       PopupMenuButton(
              //
              //         /// where the menu should appear ******
              //         position: PopupMenuPosition.under,
              //         offset: const Offset(1, 0),
              //
              //         /// where the menu should appear ******
              //         onSelected: (themeMode) =>
              //             controller.setThemeMode(themeMode as ThemeMode),
              //         itemBuilder: (BuildContext context) =>
              //         <PopupMenuEntry>[
              //           const PopupMenuItem(
              //             value: ThemeMode.light,
              //             child: Text('Light Theme'),
              //           ),
              //           const PopupMenuItem(
              //             value: ThemeMode.dark,
              //             child: Text('Dark Theme'),
              //           ),
              //           // const PopupMenuItem(
              //           //   value: ThemeMode.system,
              //           //   child: Text('System'),
              //           // ),
              //         ],
              //         child: ListTile(
              //           // leading: ImageIcon(
              //           //   // const AssetImage('assets/icons/show_icon_64.png'),
              //           //   // color: Theme.of(context).iconTheme.color,
              //           //   // size: 28.sp,
              //           // ),
              //           title: Text('Theme'.tr),
              //           trailing: Icon(
              //             Icons.arrow_forward_ios_rounded,
              //             color: Theme
              //                 .of(context)
              //                 .iconTheme
              //                 .color,
              //             size: 20.sp,
              //           ),
              //         ),
              //       ),
              //       // ListTile(
              //       //   // onTap: controller.showConfirmLogoutDialog,
              //       //   leading: ImageIcon(
              //       //     // const AssetImage('assets/icons/logout_icon_64.png'),
              //       //     // color: lightRed,
              //       //     // size: 28.sp,
              //       //   ),
              //       //   title: Text('Logout'.tr),
              //       //   trailing: Icon(
              //       //     Icons.arrow_forward_ios_rounded,
              //       //     color: Theme.of(context).iconTheme.color,
              //       //     size: 20.sp,
              //       //   ),
              //       // ),
              //       // ListTile(onTap: (){},
              //       //   leading: Icon(Icons.remove_red_eye_rounded),
              //       //   title: Text('Privacy'),
              //       //   trailing: Icon(
              //       //     Icons.arrow_forward_ios_rounded,
              //       //     color: Theme.of(context).iconTheme.color,
              //       //   ),
              //       // ),
              //     ],
              //   ),
              // )
            ],
          ),
        ),
      ),
    );
  }

  Padding buildTitle(String text) {
    return Padding(
      padding: EdgeInsets.all(15.w),
      child: Text(
        text,
        style: TextStyle(
          fontFamily: ConstantData.abelFont,
          fontSize: 16.sp,
          color: Colors.blueAccent,
        ),
      ),
    );
  }
}
