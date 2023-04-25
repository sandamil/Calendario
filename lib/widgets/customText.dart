import 'package:flutter/material.dart';

class CustomTextWidget extends StatelessWidget {
  CustomTextWidget({
    this.data,
    this.color,
    this.textAlign,
    this.fontWeight,
    this.maxLines,
    this.fontSize,
    this.textDirection,
    this.height,
    this.style,



  }) : assert(data != null);

  final String? data;
  final TextAlign? textAlign;
  final Color? color;
  final FontWeight? fontWeight;
  final double? fontSize;
  final int? maxLines;
  final double? height;
  final TextStyle? style;
  final TextDirection? textDirection;

  @override
  Widget build(BuildContext context) {
    if (data == null) {
      return SizedBox(
        height: height,
        child: Text(
          ' ',
          style:  TextStyle(
            color: color,
            fontWeight: fontWeight,
            fontSize: fontSize,
          ),
          maxLines: maxLines,
          textDirection: textDirection,
          textAlign: textAlign,
        ),
      );
    } else {
      return SizedBox(
        height: height,
        child: Text(
          data!,
          style:  TextStyle(
              color: color,
              fontWeight: fontWeight,
              fontSize: fontSize,
              ),
          maxLines: maxLines,
          textDirection: textDirection,
          textAlign: textAlign,
        ),
      );
    }
  }
}

