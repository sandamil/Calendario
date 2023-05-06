import 'package:calendario2/config/theme/my_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'dark_theme_colors.dart';
import 'my_fonts.dart';
import 'light_theme_colors.dart';

class MyStyles {
  ///icons theme
  static IconThemeData getIconTheme({required bool isLightTheme}) =>
      IconThemeData(
        color: isLightTheme
            ? LightThemeColors.iconColor
            : DarkThemeColors.iconColor,
      );

  static FloatingActionButtonThemeData getFloatingActionButtonTheme(
          {required bool isLightTheme}) =>
      FloatingActionButtonThemeData(
        backgroundColor: isLightTheme
            ? LightThemeColors.floatingActionButtonColor
            : DarkThemeColors.floatingActionButtonColor,
      );

  static TextButtonThemeData getTextButtonTheme({required bool isLightTheme}) =>
      TextButtonThemeData(
          style: ButtonStyle(
        // backgroundColor: MaterialStateColor.resolveWith((states) => Colors.black),
        foregroundColor: MaterialStateColor.resolveWith((states) => isLightTheme
            ? LightThemeColors.buttonTextColor
            : DarkThemeColors.buttonTextColor),
        overlayColor: MaterialStateColor.resolveWith((states) => isLightTheme
            ? LightThemeColors.primaryColor50
            : DarkThemeColors.primaryColor50),
      ));

  ///app bar theme
  static AppBarTheme getAppBarTheme({required bool isLightTheme}) =>
      AppBarTheme(
        systemOverlayStyle: isLightTheme
            ? const SystemUiOverlayStyle(
          // Status bar color
          statusBarColor: LightThemeColors.scaffoldBackgroundColor,
          // Status bar brightness (optional)
          statusBarIconBrightness: Brightness.dark, // For Android (dark icons)
          statusBarBrightness: Brightness.light, // For iOS (dark icons)
        )
            : const SystemUiOverlayStyle(
          // Status bar color
          statusBarColor: DarkThemeColors.scaffoldBackgroundColor,
          // Status bar brightness (optional)
          statusBarIconBrightness: Brightness.light, // For Android (dark icons)
          statusBarBrightness: Brightness.dark, // For iOS (dark icons)
        ),
        elevation: 0,
        titleTextStyle:
            getTextTheme(isLightTheme: isLightTheme).bodyLarge!.copyWith(
                  color: Colors.white,
                  fontSize: MyFonts.appBarTittleSize,
                ),
        iconTheme: IconThemeData(
            color: isLightTheme
                ? LightThemeColors.appBarIconsColor
                : DarkThemeColors.appBarIconsColor),
        backgroundColor: isLightTheme
            ? LightThemeColors.appBarColor
            : DarkThemeColors.appBarColor,
      );

  ///text theme
  static TextTheme getTextTheme({required bool isLightTheme}) => TextTheme(
        labelLarge:
            MyFonts.buttonTextStyle.copyWith(fontSize: MyFonts.buttonTextSize),
        bodyLarge: (MyFonts.bodyTextStyle).copyWith(
            fontWeight: FontWeight.bold,
            fontSize: MyFonts.body1TextSize,
            color: isLightTheme
                ? LightThemeColors.bodyTextColor
                : DarkThemeColors.bodyTextColor),
        bodyMedium: (MyFonts.bodyTextStyle).copyWith(
            fontSize: MyFonts.body2TextSize,
            color: isLightTheme
                ? LightThemeColors.bodyTextColor
                : DarkThemeColors.bodyTextColor),
        displayLarge: (MyFonts.headlineTextStyle).copyWith(
            fontSize: MyFonts.headline1TextSize,
            fontWeight: FontWeight.bold,
            color: isLightTheme
                ? LightThemeColors.headlinesTextColor
                : DarkThemeColors.headlinesTextColor),
        displayMedium: (MyFonts.headlineTextStyle).copyWith(
            fontSize: MyFonts.headline2TextSize,
            fontWeight: FontWeight.bold,
            color: isLightTheme
                ? LightThemeColors.headlinesTextColor
                : DarkThemeColors.headlinesTextColor),
        displaySmall: (MyFonts.headlineTextStyle).copyWith(
            fontSize: MyFonts.headline3TextSize,
            fontWeight: FontWeight.bold,
            color: isLightTheme
                ? LightThemeColors.headlinesTextColor
                : DarkThemeColors.headlinesTextColor),
        headlineLarge: (MyFonts.headlineTextStyle).copyWith(
            fontSize: MyFonts.headline2TextSize,
            fontWeight: FontWeight.bold,
            color: isLightTheme
                ? LightThemeColors.headlinesTextColor
                : DarkThemeColors.headlinesTextColor),
        headlineMedium: (MyFonts.headlineTextStyle).copyWith(
            fontSize: MyFonts.headline4TextSize,
            fontWeight: FontWeight.bold,
            color: isLightTheme
                ? LightThemeColors.headlinesTextColor
                : DarkThemeColors.headlinesTextColor),
        headlineSmall: (MyFonts.headlineTextStyle).copyWith(
            fontSize: MyFonts.headline5TextSize,
            fontWeight: FontWeight.bold,
            color: isLightTheme
                ? LightThemeColors.headlinesTextColor
                : DarkThemeColors.headlinesTextColor),
        titleLarge: (MyFonts.headlineTextStyle).copyWith(
            fontSize: MyFonts.headline6TextSize,
            fontWeight: FontWeight.bold,
            color: isLightTheme
                ? LightThemeColors.headlinesTextColor
                : DarkThemeColors.headlinesTextColor),
        bodySmall: TextStyle(
            color: isLightTheme
                ? LightThemeColors.captionTextColor
                : DarkThemeColors.captionTextColor,
            fontSize: MyFonts.captionTextSize),
      );

  static ChipThemeData getChipTheme({required bool isLightTheme}) {
    return ChipThemeData(
      backgroundColor: isLightTheme
          ? LightThemeColors.chipBackground
          : DarkThemeColors.chipBackground,
      brightness: Brightness.light,
      labelStyle: getChipTextStyle(isLightTheme: isLightTheme),
      secondaryLabelStyle: getChipTextStyle(isLightTheme: isLightTheme),
      selectedColor: Colors.black,
      disabledColor: Colors.green,
      padding: const EdgeInsets.all(5),
      secondarySelectedColor: Colors.purple,
    );
  }

  ///Chips text style
  static TextStyle getChipTextStyle({required bool isLightTheme}) {
    return MyFonts.chipTextStyle.copyWith(
      fontSize: MyFonts.chipTextSize,
      color: isLightTheme
          ? LightThemeColors.chipTextColor
          : DarkThemeColors.chipTextColor,
    );
  }

  // elevated button text style
  static MaterialStateProperty<TextStyle?>? getElevatedButtonTextStyle(
      bool isLightTheme,
      {bool isBold = true,
      double? fontSize}) {
    return MaterialStateProperty.resolveWith<TextStyle>(
      (Set<MaterialState> states) {
        if (states.contains(MaterialState.pressed)) {
          return MyFonts.buttonTextStyle.copyWith(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              fontSize: fontSize ?? MyFonts.buttonTextSize,
              color: isLightTheme
                  ? LightThemeColors.buttonTextColor
                  : DarkThemeColors.buttonTextColor);
        } else if (states.contains(MaterialState.disabled)) {
          return MyFonts.buttonTextStyle.copyWith(
              fontSize: fontSize ?? MyFonts.buttonTextSize,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: isLightTheme
                  ? LightThemeColors.buttonDisabledTextColor
                  : DarkThemeColors.buttonDisabledTextColor);
        }
        return MyFonts.buttonTextStyle.copyWith(
            fontSize: fontSize ?? MyFonts.buttonTextSize,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: isLightTheme
                ? LightThemeColors.buttonTextColor
                : DarkThemeColors
                    .buttonTextColor); // Use the component's default.
      },
    );
  }

  //elevated button theme data
  static ElevatedButtonThemeData getElevatedButtonTheme(
          {required bool isLightTheme}) =>
      ElevatedButtonThemeData(
        style: ButtonStyle(
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5.r),
              //side: BorderSide(color: Colors.teal, width: 2.0),
            ),
          ),
          elevation: MaterialStateProperty.all(0),
          padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
              EdgeInsets.symmetric(vertical: 8.h)),
          textStyle: getElevatedButtonTextStyle(isLightTheme),
          backgroundColor: MaterialStateProperty.resolveWith<Color>(
            (Set<MaterialState> states) {
              if (states.contains(MaterialState.pressed)) {
                return isLightTheme
                    ? LightThemeColors.buttonColor.withOpacity(0.5)
                    : DarkThemeColors.buttonColor.withOpacity(0.5);
              } else if (states.contains(MaterialState.disabled)) {
                return isLightTheme
                    ? LightThemeColors.buttonDisabledColor
                    : DarkThemeColors.buttonDisabledColor;
              }
              return isLightTheme
                  ? LightThemeColors.buttonColor
                  : DarkThemeColors.buttonColor; // Use the component's default.
            },
          ),
        ),
      );

  //timepicker theme data
  static TimePickerThemeData getTimePickerTheme({required bool isLightTheme}) =>
      TimePickerThemeData(
        backgroundColor: isLightTheme
            ? LightThemeColors.cardColor
            : DarkThemeColors.cardColor,
        hourMinuteShape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(5)),
          side: BorderSide(color: Colors.orange, width: 1),
        ),
        dayPeriodBorderSide: const BorderSide(color: Colors.orange, width: 1),
        dayPeriodColor: Colors.blueGrey.shade600,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(5)),
          side: BorderSide(color: Colors.orange, width: 1),
        ),
        dayPeriodTextColor: Colors.white,
        dayPeriodShape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(5)),
          side: BorderSide(color: Colors.orange, width: 1),
        ),
        hourMinuteColor: MaterialStateColor.resolveWith(
            (states) => states.contains(MaterialState.selected)
                ? Colors.orange
                : isLightTheme
                    ? LightThemeColors.scaffoldBackgroundColor
                    : DarkThemeColors.scaffoldBackgroundColor),
        hourMinuteTextColor: MaterialStateColor.resolveWith((states) =>
            states.contains(MaterialState.selected)
                ? Colors.white
                : Colors.orange),
        dialHandColor: isLightTheme
            ? LightThemeColors.dividerColor
            : DarkThemeColors.dividerColor,
        dialBackgroundColor: isLightTheme
            ? LightThemeColors.scaffoldBackgroundColor
            : DarkThemeColors.scaffoldBackgroundColor,
        hourMinuteTextStyle:
            const TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
        dayPeriodTextStyle:
            const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
        helpTextStyle: TextStyle(
            fontSize: 14.sp, fontWeight: FontWeight.bold, color: isLightTheme
            ? LightThemeColors.bodyTextColor
            : DarkThemeColors.bodyTextColor,),
        // helpTextStyle: TextStyle(
        //   fontSize: 16.sp, fontWeight: FontWeight.bold, color: isLightTheme
        //     ? LightThemeColors.bodyTextColor
        //     : DarkThemeColors.bodyTextColor,),

        inputDecorationTheme: InputDecorationTheme(
          errorStyle: const TextStyle(color: Colors.blue),
          prefixIconColor: isLightTheme
              ? LightThemeColors.darkTextColor
              : DarkThemeColors.lightTextColor,
          suffixIconColor: isLightTheme
              ? LightThemeColors.darkTextColor
              : DarkThemeColors.lightTextColor,
          labelStyle: TextStyle(
            color: isLightTheme
                ? LightThemeColors.darkTextColor
                : DarkThemeColors.lightTextColor,
          ),
          hintStyle: TextStyle(color: isLightTheme
              ? LightThemeColors.darkTextColor.withOpacity(0.8)
              : DarkThemeColors.lightTextColor.withOpacity(0.8), fontSize: 18, fontWeight: FontWeight.w200),
          enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                width: 4.0,
                color: isLightTheme
                    ? LightThemeColors.dividerColor
                    : DarkThemeColors.dividerColor,
              )),

          errorBorder: const UnderlineInputBorder(
              borderSide: BorderSide(width: 0.7, color: Colors.red)),
          focusedErrorBorder: const UnderlineInputBorder(
              borderSide: BorderSide(width: 3, color: Colors.redAccent)),
          focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(width: 4, color: Colors.orange)),
          border: const UnderlineInputBorder(
              borderSide: BorderSide(width: 2.0, color: Colors.redAccent)),
          disabledBorder: const UnderlineInputBorder(
              borderSide: BorderSide(
                  width: 2.0,
                  color:
                  Colors.redAccent)),
        ),
        // inputDecorationTheme: InputDecorationTheme(
        //   errorBorder: const UnderlineInputBorder(
        //       borderSide: BorderSide(width: 0.7, color: Colors.red)),
        //   focusedErrorBorder: const UnderlineInputBorder(
        //       borderSide: BorderSide(width: 3, color: Colors.redAccent)),
        //   focusedBorder: const UnderlineInputBorder(
        //       borderSide: BorderSide(width: 4, color: Colors.orange)),
        //   enabledBorder: UnderlineInputBorder(
        //       borderSide: BorderSide(
        //     width: 4.0,
        //     color: isLightTheme
        //         ? LightThemeColors.dividerColor
        //         : DarkThemeColors.dividerColor,
        //   )),
        //   border: const UnderlineInputBorder(
        //       borderSide: BorderSide(width: 2.0, color: Colors.redAccent)),
        //   disabledBorder: const UnderlineInputBorder(
        //       borderSide: BorderSide(
        //           width: 2.0,
        //           color:
        //               Colors.redAccent)), // contentPadding: EdgeInsets.all(14),
        // ),
        dialTextColor: MaterialStateColor.resolveWith(
            (states) => states.contains(MaterialState.selected)
                ? Colors.orange
                : isLightTheme
                    ? LightThemeColors.bodyTextColor
                    : DarkThemeColors.bodyTextColor),
        entryModeIconColor: Colors.orange,
      );

  // static InputDecorationTheme getInputDecorationTheme(
  //         {required bool isLightTheme}) =>
  //     const InputDecorationTheme(
  //       // focusedErrorBorder: UnderlineInputBorder(
  //       //     borderSide: BorderSide(width: 0.7, color: errorColor)),
  //       // focusedBorder: UnderlineInputBorder(
  //       //     borderSide: BorderSide(width: 0.5, color: primaryColor)),
  //       enabledBorder: UnderlineInputBorder(
  //           borderSide: BorderSide(width: 2.0, color: Colors.redAccent)),
  //       border: UnderlineInputBorder(
  //           borderSide: BorderSide(width: 2.0, color: Colors.redAccent)),
  //       // disabledBorder: UnderlineInputBorder(
  //       //     borderSide: BorderSide(width: 2.0, color: disabledColor)),
  //     );

  // static InputDecorationTheme getInputDecorationTheme2(
  //         {required bool isLightTheme}) =>
  //      InputDecorationTheme(
  //         border: OutlineInputBorder(
  //           borderRadius: BorderRadius.circular(28),
  //           borderSide: BorderSide(color: isLightTheme
  //               ? LightThemeColors.dividerColor
  //               : DarkThemeColors.dividerColor,),
  //         ),
  //         );
}
