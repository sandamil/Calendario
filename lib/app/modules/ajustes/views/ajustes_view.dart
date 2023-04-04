import 'dart:developer';
import 'dart:io';

import 'package:calendario2/config/translations/localization_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:get/get.dart';

import '../controllers/ajustes_controller.dart';

class AjustesView extends GetView<AjustesController> {

  const AjustesView({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Settings'.tr,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [

          Divider(
            indent: 15.w,
            endIndent: 15.w,
          ),
          Expanded(
            child: ListView(
              children: [
                ListTile(
                  // onTap: controller.goToEditProfile,
                  // leading: ImageIcon(
                  //   const AssetImage('assets/images/iconos/profile_icon_64.png'),
                  //   color: Theme.of(context).iconTheme.color,
                  //   size: 28.sp,
                  // ),
                  title: Text('Edit Profile'.tr),
                  trailing: Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: Theme.of(context).iconTheme.color,
                    size: 20.sp,
                  ),
                ),
                ListTile(
                  // onTap: controller.goToShippingAddresses,
                  // leading: ImageIcon(
                  //   const AssetImage('assets/images/iconos/location_icon_64.png'),
                  //   color: Theme.of(context).iconTheme.color,
                  //   size: 28.sp,
                  // ),
                  title: Text('Address'.tr),
                  trailing: Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: Theme.of(context).iconTheme.color,
                    size: 20.sp,
                  ),
                ),
                ListTile(
                  onTap: () {},
                  // leading: ImageIcon(
                  //   const AssetImage('assets/images/iconos/notification_icon_64.png'),
                  //   color: Theme.of(context).iconTheme.color,
                  //   size: 28.sp,
                  // ),
                  title: Text('Notification'.tr),
                  trailing: Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: Theme.of(context).iconTheme.color,
                    size: 20.sp,
                  ),
                ),
                ListTile(
                  onTap: controller.goToLanguageScreen,
                  leading: ImageIcon(
                    const AssetImage('assets/images/iconos/language_icon_64.png'),
                    color: Theme.of(context).iconTheme.color,
                    size: 28.sp,
                  ),
                  title: Text('Language'.tr),
                  trailing: Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: Theme.of(context).iconTheme.color,
                    size: 20.sp,
                  ),
                ),
                PopupMenuButton(
                  /// where the menu should appear ******
                  position: PopupMenuPosition.under,
                  offset: const Offset(1, 0),

                  /// where the menu should appear ******
                  onSelected: (themeMode) => controller.setThemeMode(themeMode as ThemeMode),
                  itemBuilder: (BuildContext context) => <PopupMenuEntry>[
                    const PopupMenuItem(
                      value: ThemeMode.light,
                      child: Text('Light Theme'),
                    ),
                    const PopupMenuItem(
                      value: ThemeMode.dark,
                      child: Text('Dark Theme'),
                    ),
                    // const PopupMenuItem(
                    //   value: ThemeMode.system,
                    //   child: Text('System'),
                    // ),
                  ],
                  child: ListTile(
                    // leading: ImageIcon(
                    //   // const AssetImage('assets/icons/show_icon_64.png'),
                    //   // color: Theme.of(context).iconTheme.color,
                    //   // size: 28.sp,
                    // ),
                    title: Text('Theme'.tr),
                    trailing: Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: Theme.of(context).iconTheme.color,
                      size: 20.sp,
                    ),
                  ),
                ),
                // ListTile(
                //   // onTap: controller.showConfirmLogoutDialog,
                //   leading: ImageIcon(
                //     // const AssetImage('assets/icons/logout_icon_64.png'),
                //     // color: lightRed,
                //     // size: 28.sp,
                //   ),
                //   title: Text('Logout'.tr),
                //   trailing: Icon(
                //     Icons.arrow_forward_ios_rounded,
                //     color: Theme.of(context).iconTheme.color,
                //     size: 20.sp,
                //   ),
                // ),
                // ListTile(onTap: (){},
                //   leading: Icon(Icons.remove_red_eye_rounded),
                //   title: Text('Privacy'),
                //   trailing: Icon(
                //     Icons.arrow_forward_ios_rounded,
                //     color: Theme.of(context).iconTheme.color,
                //   ),
                // ),
              ],
            ),
          )
        ],
      ),
    );

  }
}
