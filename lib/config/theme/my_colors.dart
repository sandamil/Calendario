import 'package:calendario2/config/theme/my_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../app/data/local/my_shared_pref.dart';
import '../translations/localization_service.dart';

// todo configure text family and size
class MyColors {

  static Color get backgroundColor => MyTheme().getThemeIsLight
      ? const Color(0xffebeaea)
      :  const Color(0xff303030);





  static Color get disableBgColorBtn => MyTheme().getThemeIsLight
      ? const Color(0xFFEBEAEF)
      :  const Color(0xff525252);

  // Color Cell Calendar
  static Color get cellColor => MyTheme().getThemeIsLight
      ? const Color(0xFFefeeee)
      : const Color(0xFF2b2b2b);
  static Color get cellTodayColor => MyTheme().getThemeIsLight
      ? const Color(0xFFefeeee)
      : const Color(0xff353535);
  static Color get cellSelectedColor => MyTheme().getThemeIsLight
      ? const Color(0xFFfdfcfc)
      : const Color(0xff444444);

  //Todo bordercell color

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

  //Todo cellTextColor color

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
const Color ACCENT_COLOR = Color(0xff005AFF);
const Color PRIMARY_COLOR_TRANSPARENTE = Color.fromRGBO(
    255, 152, 0, 0.15);
const Color PRIMARY_COLOR_DARK = Color.fromRGBO(215, 129, 0, 1.0);



