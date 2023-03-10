import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';


class InputField extends StatelessWidget {
  const InputField({
    Key? key,
    required this.label,
    required this.hintText,
    this.controller,
    this.widget,
  }) : super(key: key);
  final String label;
  final String hintText;
  final TextEditingController? controller;
  final Widget? widget;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: titleStyle),
          Container(
            // width: SizeConfig.screenWidth,
            height: 52,
            padding: const EdgeInsets.only(left: 8),
            margin: const EdgeInsets.only(top: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: controller,
                    cursorColor:
                        Get.isDarkMode ? Colors.grey[100] : Colors.grey[700],
                    readOnly: widget != null,
                    style: subTitleStyle,
                    decoration: InputDecoration(
                      hintText: hintText,
                      hintStyle: subTitleStyle,
                      enabledBorder:
                          const OutlineInputBorder(borderSide: BorderSide.none),
                      focusedBorder:
                          const OutlineInputBorder(borderSide: BorderSide.none),
                    ),
                  ),
                ),
                widget ?? Container(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
TextStyle get titleStyle => GoogleFonts.cabin(
    textStyle: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.bold,
      color: Get.isDarkMode ? Colors.white : Colors.black,
    ));
TextStyle get subTitleStyle => GoogleFonts.cabin(
    textStyle: TextStyle(
      fontSize: 14,
      color: Get.isDarkMode ? Colors.white : Colors.black,
    ));
