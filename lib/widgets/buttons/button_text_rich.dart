
import 'package:calendario2/config/theme/my_colors.dart';
import 'package:calendario2/config/theme/my_fonts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ButtonTextRich extends StatelessWidget {
  const ButtonTextRich({
    required this.label1,
    required this.label2,
    required this.onPressed,
    Key? key,
  }) : super(key: key);

  final String label1;
  final String label2;
  final Function() onPressed;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: ButtonStyle(
        overlayColor: MaterialStateProperty.all(Colors.grey.withOpacity(0.1)),
        shadowColor: MaterialStateProperty.all(Colors.transparent),
        padding: MaterialStateProperty.all(EdgeInsets.zero),
      ),
      child: RichText(
        text: TextSpan(
          text: label1,
          style: CustomTextStyle.text.copyWith(color: Colors.grey),
          children: <TextSpan>[
            TextSpan(
              text: label2,
              style: CustomTextStyle.title
                  .copyWith(color: PRIMARY_COLOR, fontSize: 14.w),
            ),
          ],
        ),
      ),
    );
  }
}
