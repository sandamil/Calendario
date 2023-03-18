import 'package:calendario2/config/theme/my_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../app/data/local/my_shared_pref.dart';
import '../translations/localization_service.dart';

// todo configure text family and size
class MyColors
{
  // Color Cell Calendar
  static Color get primary => MyTheme().getThemeIsLight ? const Color.fromRGBO(255, 152, 0, 1.0)  : const Color.fromRGBO(255, 152, 0, 1.0);
  static Color get cellColor => MyTheme().getThemeIsLight ? const Color.fromRGBO(0, 0, 0, 0.08)  : const Color.fromRGBO(255, 255, 255, 0.10);
  static Color get cellTextColor => MyTheme().getThemeIsLight ? const Color.fromRGBO(0, 0, 0, 1)  : const Color.fromRGBO(255, 255, 255, 1);
  static Color get cellColorSelected => MyTheme().getThemeIsLight ? Colors.transparent : Colors.white12;


}

