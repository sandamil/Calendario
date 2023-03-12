import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

// TODO add your light theme colors palette
class LightThemeColors
{
  //dark swatch
  static const Color primaryColor = Colors.orange;
  static const Color primaryColor50 = const Color(0x80FF9800);
  static Color accentColor = Colors.blueAccent;

  //APPBAR
  static const Color appBarColor = primaryColor;

  //SCAFFOLD
  static const Color scaffoldBackgroundColor = Colors.white;
  static const Color backgroundColor = Colors.white;
  static const Color dividerColor = Color(0xff686868);
  static const Color cardColor = Color(0xfffafafa);

  //ICONS
  static const Color appBarIconsColor = Colors.white;
  static const Color iconColor = primaryColor;

  //BUTTON
  static const Color buttonColor = primaryColor;
  static const Color floatingActionButtonColor = primaryColor;

  static const Color buttonTextColor = Colors.white;
  static const Color buttonDisabledColor = Colors.grey;
  static const Color buttonDisabledTextColor = Colors.black;

  //TEXT
  static const Color bodyTextColor = Colors.black;
  static const Color headlinesTextColor = Colors.black;
  static const Color captionTextColor = Colors.grey;
  static const Color hintTextColor =  Color(0xff686868);

  //chip
  static const Color chipBackground = primaryColor;
  static const Color chipTextColor = Colors.white;

  // progress bar indicator
  static const Color progressIndicatorColor = Color(0xFF40A76A);
}