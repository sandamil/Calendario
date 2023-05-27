import 'package:calendario2/config/theme/my_theme.dart';
import 'package:flutter/material.dart';

class MyColors {
  static Color get backgroundColor => MyTheme().getThemeIsLight
      ? const Color(0xffebeaea)
      : const Color(0xff303030);

  static Color get menuCardBackground => MyTheme().getThemeIsLight
      ? const Color(0xfff5f3f1)
      : const Color(0xff444444);

  static Color get disableBgColorBtn => MyTheme().getThemeIsLight
      ? const Color(0xFFEBEAEF)
      : const Color(0xff525252);

  static Color get botonBgColor => MyTheme().getThemeIsLight
      ? const Color(0xFFEEEDED)
      : const Color(0xFF524E4C);

  static Color get backgroundLowAccent => MyTheme().getThemeIsLight
      ? const Color(0xFFefeeee)
      : const Color(0xFF2b2b2b);

  // Color Cell Calendar
  static Color get cellColor => MyTheme().getThemeIsLight
      ? const Color(0xffffffff)
      : const Color(0xFF2b2b2b);
  static Color get cellTodayColor => MyTheme().getThemeIsLight
      ? const Color(0xFFefeeee)
      : const Color(0xff353535);
  static Color get cellSelectedColor => MyTheme().getThemeIsLight
      ? const Color(0xFFfdfcfc)
      : const Color(0xff444444);

  static Color get borderCellColor => MyTheme().getThemeIsLight
      ? const Color(0xffe3dcd4)
      : const Color(0xff3a3835);

  static Color get borderAccentLine => MyTheme().getThemeIsLight
      ? const Color(0xff444444)
      : const Color(0xFFefeeee);

  ///Text COLOR

  static Color get textColor => MyTheme().getThemeIsLight
      ? const Color.fromRGBO(0, 0, 0, 1)
      : const Color.fromRGBO(255, 255, 255, 1);

  static Color get cellTextColor => MyTheme().getThemeIsLight
      ? const Color.fromRGBO(0, 0, 0, 1)
      : const Color.fromRGBO(255, 255, 255, 1);

  static Color get textButtom => MyTheme().getThemeIsLight
      ? const Color(0xFFefeeee)
      : const Color(0xFF2b2b2b);

  static Color get textButtomBlack => MyTheme().getThemeIsLight
      ? const Color(0xFF2b2b2b)
      : const Color(0xFFefeeee);

  static Color get textColorPrimary => MyTheme().getThemeIsLight
      ? const Color.fromRGBO(21, 16, 0, 1.0)
      : const Color.fromRGBO(252, 169, 57, 1.0);

  static Color get textDisable => MyTheme().getThemeIsLight
      ? const Color(0xffa2a2a2)
      : const Color(0xff676767);


}



const Color PRIMARY_COLOR = Color.fromRGBO(255, 152, 0, 1.0);
const Color PRIMARY_COLOR_ICON_GREY = Color.fromRGBO(242, 242, 242, 1.0);
const Color PRIMARY_COLOR_ICON_GREY_BLACK = Color.fromRGBO(102, 102, 102, 1.0);
// const Color PRIMARY_COLOR = Colors.black;
// const Color PRIMARY_COLOR = Color.fromRGBO(215, 129, 0, 1.0);
const Color ACCENT_COLOR = Color(0xff005AFF);
const Color PRIMARY_COLOR_TRANSPARENTE = Color.fromRGBO(255, 152, 0, 0.15);
const Color PRIMARY_COLOR_DARK = Color.fromRGBO(215, 129, 0, 1.0);

const Color accent1 = Color(0xFFE4935D);
const Color accent2 = Color(0xFFBEABA1);
const Color offWhite = Color(0xFFF8ECE5);
const Color caption = Color(0xFF7D7873);
const Color body = Color(0xFF514F4D);
const Color greyStrong = Color(0xFF272625);
const Color greyMedium = Color(0xFF9D9995);
const Color white = Colors.white;
const Color black = Color(0xFF1E1B18);