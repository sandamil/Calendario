import 'package:calendario2/config/util/hexColor.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

// TODO add your dark theme colors palette
class DarkThemeColors
{
  //dark swatch
  static const Color primaryColor = Colors.orange;
  static const Color primaryColor50 = const Color(0x80FF9800);
  static Color accentColor = Colors.blueAccent;

  //Appbar
  static const Color appbarColor = Colors.black;

  //SCAFFOLD
  static const Color scaffoldBackgroundColor = Color(0xff171d2d);
  static const Color backgroundColor = Color(0xff171d2d);
  static const Color dividerColor = Color(0xff686868);
  static const Color cardColor = Color(0xff1e2336);

  //ICONS
  static const Color appBarIconsColor = Colors.white;
  static const Color iconColor = primaryColor;

  //BUTTON
  static const Color buttonColor = primaryColor;
  static const Color floatingActionButtonColor = primaryColor;

  static const Color buttonTextColor = Colors.black;
  static const Color buttonDisabledColor = Colors.grey;
  static const Color buttonDisabledTextColor = Colors.black;

  //TEXT
  static const Color bodyTextColor = Colors.white70;
  static const Color headlinesTextColor = primaryColor;
  static const Color captionTextColor = Colors.grey;
  static const Color hintTextColor = Color(0xff686868);

  //chip
  static const Color chipBackground = primaryColor;
  static const Color chipTextColor = Colors.black87;

  // progress bar indicator
  static const Color progressIndicatorColor = Color(0xFF40A76A);
}