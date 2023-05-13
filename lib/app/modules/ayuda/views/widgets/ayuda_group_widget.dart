import 'package:calendario2/config/theme/my_colors.dart';
import 'package:flutter/material.dart';


class SettingsGroup extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const SettingsGroup({Key? key, required this.title, required this.children})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: Text(
          title,
          style: TextStyle(
              color: MyColors.textColor.withOpacity(0.3),
              fontSize: 26,
              fontWeight: FontWeight.w800),
        ),
      ),
      ...children,
    ]);
  }
}

