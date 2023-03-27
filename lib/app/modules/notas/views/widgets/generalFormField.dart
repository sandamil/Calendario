import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class GeneralFormField extends StatelessWidget {
  late TextEditingController value;
  late String hint;
  late int lines;

  GeneralFormField( TextEditingController title, String s, int i);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: value,
      decoration: InputDecoration(
        filled: true,
        contentPadding: const EdgeInsets.only(left: 20, top: 20),
        fillColor: Colors.white12,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(10.r),
          ),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(10.r),
            ),
            borderSide: const BorderSide(
              color: Colors.green,
              width: 2,
            )),
        hintText: hint,
      ),
      maxLines: lines,
    );
  }
}
