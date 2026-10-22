import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../../../config/util/app_icons.dart';

class ExampleAlarmTile extends StatelessWidget {
  final String title;
  final void Function() onPressed;
  const ExampleAlarmTile({super.key, required this.title, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final text = theme.colorScheme.onSurface;
    return Material(
      color: theme.colorScheme.surfaceContainerHighest.withOpacity(.48),
      borderRadius: BorderRadius.circular(15.r),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(15.r),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 11.h, horizontal: 12.w),
          child: Row(
            children: [
              Container(
                width: 36.w,
                height: 36.w,
                decoration: BoxDecoration(color: Colors.green.withOpacity(.13), borderRadius: BorderRadius.circular(11.r)),
                child: const Center(child: AppIcon(AppIcons.telefono_alarma, color: Colors.green)),
              ),
              SizedBox(width: 10.w),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Recordatorio creado', style: TextStyle(fontSize: 12.sp, color: text.withOpacity(.62))),
                SizedBox(height: 2.h),
                Text(title, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w800, color: text)),
              ])),
              Icon(Icons.chevron_right_rounded, size: 20.sp, color: text.withOpacity(.45)),
            ],
          ),
        ),
      ),
    );
  }
}
