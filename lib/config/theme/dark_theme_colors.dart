import 'package:calendario2/config/util/hexColor.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

// TODO add your dark theme colors palette
class DarkThemeColors
{
  //dark swatch
  static const Color primaryColor = const Color(0xFFFFA500);
  static const Color primaryColor50 = const Color(0x80FFA500);
  static Color accentColor = const Color(0xff005AFF);

  //APPBAR
  static const Color appBarColor = const Color(0xFFA500);

  //SCAFFOLD
  static const Color scaffoldBackgroundColor = Color(0xff303030);
  static const Color backgroundColor = Color(0xff333333);
  static const Color dividerColor = Color(0xff898276);
  static const Color cardColor = Color(0xff353535);

  //ICONS
  static const Color appBarIconsColor = Colors.white;
  static const Color iconColor = primaryColor;

  //BUTTON
  static const Color buttonColor = primaryColor;
  static const Color floatingActionButtonColor = primaryColor;

  static const Color buttonTextColor = Colors.white;
  static const Color buttonDisabledColor = Colors.grey;
  static const Color buttonDisabledTextColor = Colors.black12;

  //TEXT
  static const Color bodyTextColor = Color(0xe5ffffff);
  static const Color headlinesTextColor =  Color(0xe5ffffff);
  static const Color captionTextColor = Colors.grey;
  static const Color hintTextColor = Color(0xff686868);

  //chip
  static const Color chipBackground = primaryColor;
  static const Color chipTextColor = Colors.black87;

  // progress bar indicator
  static const Color progressIndicatorColor = Color(0xFF40A76A);
}