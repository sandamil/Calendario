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
        // backgroundColor: WidgetStateColor.resolveWith((states) => Colors.black),
        foregroundColor: WidgetStateColor.resolveWith((states) => isLightTheme
            ? LightThemeColors.buttonTextColor
            : DarkThemeColors.buttonTextColor),
        overlayColor: WidgetStateColor.resolveWith((states) => isLightTheme
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
                statusBarIconBrightness:
                    Brightness.dark, // For Android (dark icons)
                statusBarBrightness: Brightness.light, // For iOS (dark icons)

                systemNavigationBarColor:
                    LightThemeColors.scaffoldBackgroundColor,
                systemNavigationBarDividerColor:
                    LightThemeColors.scaffoldBackgroundColor,
                systemNavigationBarIconBrightness: Brightness.dark,
              )
            : const SystemUiOverlayStyle(
                // Status bar color
                statusBarColor: DarkThemeColors.scaffoldBackgroundColor,
                // Status bar brightness (optional)
                statusBarIconBrightness:
                    Brightness.light, // For Android (dark icons)
                statusBarBrightness: Brightness.dark, // For iOS (dark icons)

                systemNavigationBarColor:
                    DarkThemeColors.scaffoldBackgroundColor,
                systemNavigationBarDividerColor:
                    DarkThemeColors.scaffoldBackgroundColor,
                systemNavigationBarIconBrightness: Brightness.light,
              ),
        elevation: 0,
        titleTextStyle:
            getTextTheme(isLightTheme: isLightTheme).bodyLarge!.copyWith(
                  color: isLightTheme
                      ? LightThemeColors.bodyTextColor
                      : DarkThemeColors.bodyTextColor,
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
    final primaryColor = isLightTheme
        ? LightThemeColors.primaryColor
        : DarkThemeColors.primaryColor;
    final disabledColor = isLightTheme
        ? LightThemeColors.buttonDisabledColor
        : DarkThemeColors.buttonDisabledColor;

    return ChipThemeData(
      backgroundColor: isLightTheme
          ? LightThemeColors.chipBackground
          : DarkThemeColors.chipBackground,
      brightness: isLightTheme ? Brightness.light : Brightness.dark,
      labelStyle: getChipTextStyle(isLightTheme: isLightTheme),
      secondaryLabelStyle: getChipTextStyle(isLightTheme: isLightTheme),
      selectedColor: primaryColor,
      disabledColor: disabledColor,
      padding: const EdgeInsets.all(5),
      secondarySelectedColor: primaryColor,
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
  static WidgetStateProperty<TextStyle?>? getElevatedButtonTextStyle(
      bool isLightTheme,
      {bool isBold = true,
      double? fontSize}) {
    return WidgetStateProperty.resolveWith<TextStyle>(
      (Set<WidgetState> states) {
        if (states.contains(WidgetState.pressed)) {
          return MyFonts.buttonTextStyle.copyWith(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              fontSize: fontSize ?? MyFonts.buttonTextSize,
              color: isLightTheme
                  ? LightThemeColors.buttonTextColor
                  : DarkThemeColors.buttonTextColor);
        } else if (states.contains(WidgetState.disabled)) {
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
          shape: WidgetStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5.r),
              //side: BorderSide(color: Colors.teal, width: 2.0),
            ),
          ),
          elevation: WidgetStateProperty.all(0),
          padding: WidgetStateProperty.all<EdgeInsetsGeometry>(
              EdgeInsets.symmetric(vertical: 8.h)),
          textStyle: getElevatedButtonTextStyle(isLightTheme),
          backgroundColor: WidgetStateProperty.resolveWith<Color>(
            (Set<WidgetState> states) {
              if (states.contains(WidgetState.pressed)) {
                return isLightTheme
                    ? LightThemeColors.buttonColor.withValues(alpha: 0.5)
                    : DarkThemeColors.buttonColor.withValues(alpha: 0.5);
              } else if (states.contains(WidgetState.disabled)) {
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
        dayPeriodColor: isLightTheme
            ? LightThemeColors.cardColor
            : DarkThemeColors.scaffoldBackgroundColor,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(5)),
          side: BorderSide(color: Colors.orange, width: 1),
        ),
        dayPeriodTextColor: isLightTheme
            ? LightThemeColors.bodyTextColor
            : DarkThemeColors.bodyTextColor,
        dayPeriodShape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(5)),
          side: BorderSide(color: Colors.orange, width: 1),
        ),
        hourMinuteColor: WidgetStateColor.resolveWith(
            (states) => states.contains(WidgetState.selected)
                ? Colors.orange
                : isLightTheme
                    ? LightThemeColors.scaffoldBackgroundColor
                    : DarkThemeColors.scaffoldBackgroundColor),
        hourMinuteTextColor: WidgetStateColor.resolveWith((states) =>
            states.contains(WidgetState.selected)
                ? Colors.black
                : isLightTheme
                    ? LightThemeColors.bodyTextColor
                    : DarkThemeColors.bodyTextColor),
        dialHandColor: const Color(0xFFFF9800),
        dialBackgroundColor: isLightTheme
            ? LightThemeColors.scaffoldBackgroundColor
            : DarkThemeColors.scaffoldBackgroundColor,
        hourMinuteTextStyle:
            const TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
        dayPeriodTextStyle:
            const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
        helpTextStyle: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.bold,
          color: isLightTheme
              ? LightThemeColors.bodyTextColor
              : DarkThemeColors.bodyTextColor,
        ),
        // helpTextStyle: TextStyle(
        //   fontSize: 16.sp, fontWeight: FontWeight.bold, color: isLightTheme
        //     ? LightThemeColors.bodyTextColor
        //     : DarkThemeColors.bodyTextColor,),

        inputDecorationTheme: InputDecorationTheme(

          errorStyle: TextStyle(
            color: isLightTheme ? Colors.red : Colors.redAccent,
          ),
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
          hintStyle: TextStyle(
              color: isLightTheme
                  ? LightThemeColors.darkTextColor.withValues(alpha: 0.8)
                  : DarkThemeColors.lightTextColor.withValues(alpha: 0.8),
              fontSize: 18,
              fontWeight: FontWeight.w200),
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
              borderSide: BorderSide(width: 2.0, color: Colors.redAccent)),
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
        dialTextColor: WidgetStateColor.resolveWith(
            (states) => states.contains(WidgetState.selected)
                ? Colors.black
                : isLightTheme
                    ? LightThemeColors.bodyTextColor
                    : DarkThemeColors.bodyTextColor),
        entryModeIconColor: Colors.orange,
      );

  static InputDecorationTheme getInputDecorationTheme(
          {required bool isLightTheme}) =>
       InputDecorationTheme(
          fillColor:  isLightTheme
              ? LightThemeColors.backgroundColor
              : DarkThemeColors
              .backgroundColor,

          labelStyle: const TextStyle(color: Colors.orange),
        // focusedErrorBorder: UnderlineInputBorder(
        //     borderSide: BorderSide(width: 0.7, color: errorColor)),
        focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(
                style: BorderStyle.solid,
                color: Colors.orange
            ),
          ),
        enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(width: 2.0, color: Colors.orange)),
        border: const OutlineInputBorder(
            borderSide: BorderSide(width: 2.0, color: Colors.orange)),
        // disabledBorder: UnderlineInputBorder(
        //     borderSide: BorderSide(width: 2.0, color: disabledColor)),
      );

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
