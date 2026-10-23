import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AyudaRowWidget extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  const AyudaRowWidget({super.key, required this.title, required this.subtitle, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final text = theme.colorScheme.onSurface;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15.r),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 13.w, vertical: 11.h),
        child: Row(
          children: [
            Container(
              width: 38.w,
              height: 38.w,
              decoration: BoxDecoration(color: theme.colorScheme.primary.withValues(alpha: .12), borderRadius: BorderRadius.circular(12.r)),
              child: Icon(Icons.arrow_outward_rounded, color: theme.colorScheme.primary, size: 19.sp),
            ),
            SizedBox(width: 11.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(color: text, fontSize: 14.sp, fontWeight: FontWeight.w700)),
                  SizedBox(height: 3.h),
                  Text(subtitle, style: TextStyle(color: text.withValues(alpha: .62), fontSize: 12.sp, height: 1.3)),
                ],
              ),
            ),
            SizedBox(width: 6.w),
            Icon(Icons.chevron_right_rounded, size: 21.sp, color: text.withValues(alpha: .45)),
          ],
        ),
      ),
    );
  }
}
