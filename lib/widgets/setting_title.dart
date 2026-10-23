import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../config/theme/my_colors.dart';

class SettingTile extends StatelessWidget {
  final Widget? icon;
  final String? btnText;
  final Widget? trailing;
  final void Function()? onPressed;
  const SettingTile({super.key, this.icon, this.btnText, this.trailing, this.onPressed});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final text = theme.colorScheme.onSurface;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Material(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(17.r),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(17.r),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 13.w, vertical: 9.h),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(17.r),
              border: Border.all(color: theme.colorScheme.outlineVariant.withValues(alpha: .35)),
            ),
            child: Row(
              children: [
                Container(
                  width: 40.w,
                  height: 40.w,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(color: PRIMARY_COLOR.withValues(alpha: .13), borderRadius: BorderRadius.circular(13.r)),
                  child: IconTheme(
                    data: IconThemeData(color: PRIMARY_COLOR, size: 21.sp),
                    child: SizedBox(width: 25.w, height: 25.w, child: FittedBox(child: icon ?? const SizedBox.shrink())),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(child: Text(btnText ?? '', maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600, color: text))),
                if (trailing != null) ...[SizedBox(width: 8.w), trailing!] else Icon(Icons.chevron_right_rounded, color: text.withValues(alpha: .4), size: 21.sp),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
