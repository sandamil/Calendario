import 'package:calendario2/config/theme/my_colors.dart';
import 'package:calendario2/config/theme/my_fonts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../config/theme/styles.dart';

class ButtonPrimary extends StatelessWidget {
  const ButtonPrimary({
    Key? key,
    this.height,
    this.width,
    this.radius,
    this.textStyle,
    this.label,
    this.color,
    this.prefixIcon,
    this.suffixIcon,
    this.onTap,
    this.padding,
    this.margin,
    this.isLoading = false,
    this.enabled = true,
    this.isOutline = false,
    this.outlineColor,
    this.textColor,
  }) : super(key: key);

  final double? height;
  final double? width;
  final double? radius;
  final TextStyle? textStyle;
  final String? label;
  final Color? color;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final Function()? onTap;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final bool enabled;
  final bool isLoading;
  final bool isOutline;
  final Color? outlineColor;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        width: isLoading ? height ?? 42.w : width ?? MediaQuery.sizeOf(context).width,
        height: height ?? 42.w,
        decoration: isOutline
            ? BoxDecoration(
                borderRadius: BorderRadius.circular(
                  isLoading ? 24.w : radius ?? Insets.xl,
                ),
                color: enabled
                    ? color ?? PRIMARY_COLOR
                    : Colors.transparent,
                border: Border.all(color: outlineColor ?? Colors.white),
              )
            : BoxDecoration(
                borderRadius: BorderRadius.circular(
                  isLoading ? 24.w : radius ?? Insets.xl,
                ),
                color: enabled
                    ? color ?? PRIMARY_COLOR
                    : PRIMARY_COLOR_TRANSPARENTE,
              ),
        child: Align(
          child: Material(
            color: Colors.transparent,
            child: isLoading
                ? const CircularProgressIndicator(
                    color: Colors.white,
                    // size: height != null ? height! - 8.w : 32.w,
                  )
                : InkWell(
                    onTap: enabled ? onTap ?? () {} : null,
                    child: Container(
                      margin: margin ?? EdgeInsets.zero,
                      padding: padding ?? EdgeInsets.zero,
                      child: Center(
                        child: Stack(
                          children: [
                            Align(
                              alignment: Alignment.centerLeft,
                              child: prefixIcon ?? const SizedBox(),
                            ),
                            Center(
                              child: Text(
                                label ?? 'BUTTON',
                                style: textStyle ??
                                    CustomTextStyle.button.copyWith(
                                      color: MyColors.textColor,
                                    ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            Align(
                              alignment: Alignment.centerRight,
                              child: suffixIcon ?? const SizedBox(),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
