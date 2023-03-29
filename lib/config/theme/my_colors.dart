import 'package:calendario2/config/theme/my_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../app/data/local/my_shared_pref.dart';
import '../translations/localization_service.dart';

// todo configure text family and size
class MyColors {
  // Color Cell Calendar

  static Color get cellColor => MyTheme().getThemeIsLight
      ? const Color.fromRGBO(201, 201, 201, 0.0784313725490196)
      : const Color.fromRGBO(255, 255, 255, 0.10);
  static Color get borderCellColor => MyTheme().getThemeIsLight
      ? GREY_DARK_COLOR
      : GREY_COLOR;
  static Color get cellTextColor => MyTheme().getThemeIsLight
      ? const Color.fromRGBO(0, 0, 0, 1)
      : const Color.fromRGBO(255, 255, 255, 1);
  static Color get cellColorSelected =>
      MyTheme().getThemeIsLight ? Colors.transparent : Colors.white12;
}


const Color PRIMARY_COLOR = Color.fromRGBO(255, 152, 0, 1.0);
const Color DEFAULT_TEXT_COLOR = Color.fromRGBO(33, 33, 33, 1);



const OLD_LACE_COLOR = Color(0xffFDF8E2);
const SKY_BLUE_COLOR = Color(0xffE4F9F8);
const LIGHT_BLUE_COLOR = Color(0xff5684AE);
const DARK_BLUE_COLOR = Color(0xff0F4C81);
const LIGHT_ORANGE_COLOR = Color(0xffFFE4C8);
const DARK_ORANGE_COLOR = Color(0xffd78100);
const CALENDAR_TITLE_COLOR = Color(0xffE4F6ED);
const GREY_COLOR = Color(0xffbebaaf);
const GREY_DARK_COLOR = Color(0xff232221);