import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';



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
          Text(label),
          Container(
            // width: SizeConfig.screenWidth,
            height: 52,
            padding: const EdgeInsets.only(left: 8),
            margin: const EdgeInsets.only(top: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5.r),
              border: Border.all(color: Theme.of(context).dividerColor),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: controller,
                    cursorColor: Theme.of(context).colorScheme.primary,
                    readOnly: widget != null,
                    // style: subTitleStyle,
                    decoration: InputDecoration(
                      hintText: hintText,
                      // hintStyle: subTitleStyle,
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

