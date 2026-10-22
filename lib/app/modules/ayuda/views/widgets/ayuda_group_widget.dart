import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SettingsGroup extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const SettingsGroup({super.key, required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(5.w, 16.h, 5.w, 8.h),
          child: Text(
            title.toUpperCase(),
            style: TextStyle(
              color: theme.colorScheme.onSurface.withOpacity(.55),
              fontSize: 11.sp,
              letterSpacing: .8,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(vertical: 4.h),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(18.r),
            border: Border.all(color: theme.colorScheme.outlineVariant.withOpacity(.4)),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }
}
