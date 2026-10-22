import 'package:flutter/material.dart';
import '../../app/data/local/my_shared_pref.dart';

import 'dark_theme_colors.dart';
import 'light_theme_colors.dart';
import 'my_colors.dart';
import 'my_styles.dart';

class MyTheme {
  static getThemeData({required bool isLight}) {
    return ThemeData(
      useMaterial3: true,
      cardTheme: CardThemeData(
        elevation: 0,
        margin: EdgeInsets.zero,
        color: isLight ? LightThemeColors.cardColor : DarkThemeColors.cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        surfaceTintColor: Colors.transparent,
      ),
      dialogTheme: DialogThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        surfaceTintColor: Colors.transparent,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: isLight ? LightThemeColors.cardColor : DarkThemeColors.cardColor,
        surfaceTintColor: Colors.transparent,
        showDragHandle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),
      listTileTheme: ListTileThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),

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
      colorScheme: isLight
          ? ColorScheme.light(
              primary: PRIMARY_COLOR,
              onPrimary: Colors.black,
              secondary: PRIMARY_COLOR,
              onSecondary: Colors.black,
              surface: LightThemeColors.cardColor,
              onSurface: LightThemeColors.bodyTextColor,
              background: LightThemeColors.backgroundColor,
              onBackground: LightThemeColors.bodyTextColor,
              error: Colors.red,
              onError: Colors.white,
            )
          : ColorScheme.dark(
              primary: PRIMARY_COLOR,
              onPrimary: Colors.black,
              secondary: PRIMARY_COLOR,
              onSecondary: Colors.black,
              surface: DarkThemeColors.cardColor,
              onSurface: DarkThemeColors.bodyTextColor,
              background: DarkThemeColors.backgroundColor,
              onBackground: DarkThemeColors.bodyTextColor,
              error: Colors.redAccent,
              onError: Colors.white,
            ),

      datePickerTheme: DatePickerThemeData(
        backgroundColor: isLight
            ? LightThemeColors.cardColor
            : DarkThemeColors.cardColor,
        headerBackgroundColor: PRIMARY_COLOR,
        headerForegroundColor: Colors.black,
        surfaceTintColor: Colors.transparent,
        todayForegroundColor:
            MaterialStateProperty.all(PRIMARY_COLOR),
        todayBorder: const BorderSide(color: PRIMARY_COLOR),
        yearForegroundColor:
            MaterialStateProperty.resolveWith<Color?>((states) {
          if (states.contains(MaterialState.selected)) {
            return Colors.black;
          }
          return isLight
              ? LightThemeColors.bodyTextColor
              : DarkThemeColors.bodyTextColor;
        }),
        yearBackgroundColor:
            MaterialStateProperty.resolveWith<Color?>((states) {
          if (states.contains(MaterialState.selected)) {
            return PRIMARY_COLOR;
          }
          return Colors.transparent;
        }),
        dayForegroundColor:
            MaterialStateProperty.resolveWith<Color?>((states) {
          if (states.contains(MaterialState.selected)) {
            return Colors.black;
          }
          if (states.contains(MaterialState.disabled)) {
            return isLight ? Colors.black38 : Colors.white30;
          }
          return isLight
              ? LightThemeColors.bodyTextColor
              : DarkThemeColors.bodyTextColor;
        }),
        dayBackgroundColor:
            MaterialStateProperty.resolveWith<Color?>((states) {
          if (states.contains(MaterialState.selected)) {
            return PRIMARY_COLOR;
          }
          return Colors.transparent;
        }),
        confirmButtonStyle: TextButton.styleFrom(
          foregroundColor: PRIMARY_COLOR,
        ),
        cancelButtonStyle: TextButton.styleFrom(
          foregroundColor: PRIMARY_COLOR,
        ),
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
      timePickerTheme: MyStyles.getTimePickerTheme(isLightTheme: isLight),

 // timePicker theme
      inputDecorationTheme: MyStyles.getInputDecorationTheme(isLightTheme: isLight),


      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith<Color?>((states) {
          if (states.contains(MaterialState.selected)) {
            return Colors.black;
          }
          return isLight ? Colors.grey.shade500 : Colors.grey.shade400;
        }),
        trackColor: MaterialStateProperty.resolveWith<Color?>((states) {
          if (states.contains(MaterialState.selected)) {
            return PRIMARY_COLOR;
          }
          return isLight ? Colors.black26 : Colors.white24;
        }),
      ),

      radioTheme: RadioThemeData(
        fillColor: MaterialStateProperty.resolveWith<Color?>((states) {
          if (states.contains(MaterialState.disabled)) {
            return isLight ? Colors.black38 : Colors.white30;
          }
          return PRIMARY_COLOR;
        }),
      ),


    );
  }

  static Color getSwitchColorThumb(Set<MaterialState> states) {
    if (states.contains(MaterialState.selected)) {
      return const Color(0xFF303030);
    }

    return Colors.grey;
  }

  static Color getSwitchTrackColor(Set<MaterialState> states) {
    const Set<MaterialState> interactiveStates = <MaterialState>{
      MaterialState.pressed,
      MaterialState.hovered,
      MaterialState.focused,
    };

    if (states.any(interactiveStates.contains)) {
      return const Color(0xFF505050);
    }

    if (states.contains(MaterialState.selected)) {
      return PRIMARY_COLOR;
    }

    return const Color(0xFF353535);
  }




  bool get getThemeIsLight => MySharedPref.getThemeIsLight();
}


// const Map<String, Color> dayColors = {
//   '': Colors.black,
//   'day': Colors.black,
//   'today': Colors.black38,
//   'selected': Colors.white,
//   'weekend': Colors.red,
//   'outside': Colors.grey,
// }
