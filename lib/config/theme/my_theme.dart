import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app/data/local/my_shared_pref.dart';
import 'dark_theme_colors.dart';
import 'light_theme_colors.dart';
import 'my_styles.dart';

class MyTheme {
  static getThemeData({required bool isLight}) {
    return ThemeData(

      // main color (app bar,tabs..etc)
      primaryColor: isLight
          ? LightThemeColors.primaryColor
          : DarkThemeColors.primaryColor,
      // secondary color (for checkbox,float button, radio..etc)
      // accentColor: isLight ? LightThemeColors.accentColor : DarkThemeColors.accentColor,
      // color contrast (if the theme is dark text should be white for example)
      brightness: isLight ? Brightness.light : Brightness.dark,
      // card widget background color
      cardColor:
          isLight ? LightThemeColors.cardColor : DarkThemeColors.cardColor,

      // hint text color
      hintColor: isLight
          ? LightThemeColors.hintTextColor
          : DarkThemeColors.hintTextColor,
      // divider color
      dividerColor: isLight
          ? LightThemeColors.dividerColor
          : DarkThemeColors.dividerColor,

      /// app background color

      scaffoldBackgroundColor: isLight
          ? LightThemeColors.scaffoldBackgroundColor
          : DarkThemeColors.scaffoldBackgroundColor,
      colorScheme: ColorScheme.fromSwatch().copyWith(
        brightness: isLight
            ? Brightness.light
            : Brightness.dark,
          background: isLight
              ? LightThemeColors.backgroundColor
              : DarkThemeColors.backgroundColor,
          secondary: isLight
              ? LightThemeColors.accentColor
              : DarkThemeColors.accentColor
      ),



      // progress bar theme
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: isLight
            ? LightThemeColors.primaryColor
            : DarkThemeColors.primaryColor,
      ),

      // appBar theme
      appBarTheme: MyStyles.getAppBarTheme(isLightTheme: isLight),

      // elevated button theme
      elevatedButtonTheme:
          MyStyles.getElevatedButtonTheme(isLightTheme: isLight),

      // text theme
      textTheme: MyStyles.getTextTheme(isLightTheme: isLight),

      // chip theme
      chipTheme: MyStyles.getChipTheme(isLightTheme: isLight),

      // icon theme
      iconTheme: MyStyles.getIconTheme(isLightTheme: isLight),

      // textButton theme
      textButtonTheme: MyStyles.getTextButtonTheme(isLightTheme: isLight),

      floatingActionButtonTheme: MyStyles.getFloatingActionButtonTheme(isLightTheme: isLight),



      // timePicker theme
      timePickerTheme: TimePickerThemeData(
          // inputDecorationTheme:
          // backgroundColor: Colors.green.shade200,
          hourMinuteColor: MaterialStateColor.resolveWith((states) =>
          states.contains(MaterialState.selected)
              ? LightThemeColors.primaryColor50
              : Colors.blue.withOpacity(0.2)),
          hourMinuteTextColor: MaterialStateColor.resolveWith((states) =>
          states.contains(MaterialState.selected)
              ? Colors.white
              : Colors.white30),
          dialHandColor: LightThemeColors.primaryColor50,
          // dialBackgroundColor: Colors.purple.withOpacity(0.5),
          // dialTextColor: MaterialStateColor.resolveWith((states) =>
          // states.contains(MaterialState.selected)
          //     ? Colors.green
          //     : Colors.black),
          // entryModeIconColor: Colors.yellow
          ),


    );
  }

  /// update app theme and save theme type to shared pref
  /// (so when the app is killed and up again theme will remain the same)
  static changeTheme(ThemeMode themeMode) {
    print(themeMode.name);
    // *) check if the current theme is light (default is light)
    bool isLightTheme = MySharedPref.getThemeIsLight();
    print('changeTheme=====isLightTheme ========${isLightTheme}');
    // *) store the new theme mode on get storage
    MySharedPref.setThemeIsLight(!isLightTheme);
    // print('changeTheme=======setThemeIsLight ========${MySharedPref.setThemeIsLight(!isLightTheme)}');

    // *) let GetX change theme
    MySharedPref.setThemeMode(themeMode);

    Get.changeThemeMode(themeMode);
  }

  /// check if the theme is light or dark
  bool get getThemeIsLight {
    return MySharedPref.getThemeIsLight();
  }


}



// const Map<String, Color> dayColors = {
//   '': Colors.black,
//   'day': Colors.black,
//   'today': Colors.black38,
//   'selected': Colors.white,
//   'weekend': Colors.red,
//   'outside': Colors.grey,
// };





