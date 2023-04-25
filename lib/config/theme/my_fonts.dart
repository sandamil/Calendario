import 'package:calendario2/config/theme/my_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../app/data/local/my_shared_pref.dart';
import '../translations/localization_service.dart';

class MyFonts
{
  // return the right font depending on app language
  static TextStyle get getAppFontType => LocalizationService.supportedLanguagesFontsFamilies[MySharedPref.getCurrentLocal().languageCode]!;

  // headlines text font
  static TextStyle get headlineTextStyle => getAppFontType;

  // body text font
  static TextStyle get bodyTextStyle => getAppFontType;

  // button text font
  static TextStyle get buttonTextStyle => getAppFontType;

  // app bar text font
  static TextStyle get appBarTextStyle  => getAppFontType;

  // chips text font
  static TextStyle get chipTextStyle  => getAppFontType;

  // appbar font size
  static double get appBarTittleSize => 18.sp;

  // body font size
  static double get body1TextSize => 13.sp;
  static double get body2TextSize => 13.sp;

  // headlines font size
  static double get headline1TextSize => 40.sp;
  static double get headline2TextSize => 30.sp;
  static double get headline3TextSize => 25.sp;
  static double get headline4TextSize => 20.sp;
  static double get headline5TextSize => 17.sp;
  static double get headline6TextSize => 15.sp;

  //button font size
  static double get buttonTextSize => 16.sp;

  //caption font size
  static double get captionTextSize => 13.sp;

  //chip font size
  static double get chipTextSize => 10.sp;
}




class CustomTextStyle {

  static TextStyle emojiStyle(
      {required BuildContext context,
        double fontSize = 14,
        Color? color,
        FontWeight fontWeight = FontWeight.w400}) {
    color = color ?? PRIMARY_COLOR;
    // return TextStyle(fontSize: fontSize, color: color);
    return GoogleFonts.notoEmoji(
        fontSize: fontSize, color: color, fontWeight: fontWeight);
  }

  static TextStyle appBarTitle(
      {required BuildContext context,
      double fontSize = 14,
      Color? color,
      FontWeight fontWeight = FontWeight.w400}) {
    color = color ?? PRIMARY_COLOR;
    // return TextStyle(fontSize: fontSize, color: color);
    return GoogleFonts.firaSans(
        fontSize: 30.sp, color: PRIMARY_COLOR, fontWeight: FontWeight.w800);
  }

  static TextStyle textMenu = GoogleFonts.firaSans(
    fontWeight: FontWeight.w900,
    fontSize: 50.w,
    color: PRIMARY_COLOR,
  );

  static TextStyle text = TextStyle(
    fontWeight: FontWeight.w400,
    fontSize: 14.w,
    color: MyColors.textColor,
  );

  static TextStyle title = TextStyle(
    fontWeight: FontWeight.w700,
    fontSize: 25.w,
    color: MyColors.textColor,
  );

  static TextStyle titleLarge = TextStyle(
    fontWeight: FontWeight.w900,
    fontSize: 50.sp,
    color: MyColors.textColor,
  );

  static TextStyle get desc => text.copyWith(fontSize: 12.w);

  static TextStyle get button => text.copyWith(
      fontWeight: FontWeight.w600, fontSize: 18.w, color: MyColors.textButtom);

  static TextStyle hintText = TextStyle(
    fontWeight: FontWeight.w400,
    fontSize: 16.w,
    color: MyColors.textDisable,
  );

  static TextStyle rowButomText = TextStyle(
    fontWeight: FontWeight.w500,
    fontSize: 16.w,
    color: MyColors.textColor,
  );
}
