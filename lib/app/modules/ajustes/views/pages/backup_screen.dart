import 'package:calendario2/app/modules/ajustes/providers/ajustes_provider.dart';
import 'package:calendario2/config/theme/my_fonts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class BackupScreen extends ConsumerWidget {
  const BackupScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(ajustesProvider.notifier);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        elevation: 0,
        toolbarHeight: 58.h,
        titleSpacing: 2.w,
        backgroundColor: theme.scaffoldBackgroundColor,
        iconTheme: theme.iconTheme,
        title: Text(
          'Copia de seguridad',
          style: CustomTextStyle.appBarTitle(context: context),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 28.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: EdgeInsets.all(18.w),
              decoration: BoxDecoration(
                color: colors.surfaceContainerHighest.withOpacity(.45),
                borderRadius: BorderRadius.circular(22.r),
                border: Border.all(
                  color: colors.outlineVariant.withOpacity(.45),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 48.w,
                        height: 48.w,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: colors.primary.withOpacity(.12),
                          borderRadius: BorderRadius.circular(15.r),
                        ),
                        child: Icon(
                          Icons.backup_rounded,
                          color: colors.primary,
                          size: 25.sp,
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Text(
                          'Copia completa',
                          style: TextStyle(
                            color: colors.onSurface,
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 14.h),
                  Text(
                    'Guarda todos los datos de la aplicación en un único '
                    'archivo JSON: calendario, cuadrantes, tipos de turno, '
                    'tema y notas.',
                    style: TextStyle(
                      color: colors.onSurface.withOpacity(.72),
                      fontSize: 14.sp,
                      height: 1.45,
                    ),
                  ),
                  SizedBox(height: 10.h),
                  Text(
                    'Al restaurar una copia, los datos actuales se '
                    'sustituirán por los del archivo seleccionado. '
                    'Guarda la copia en un lugar seguro.',
                    style: TextStyle(
                      color: colors.onSurface.withOpacity(.72),
                      fontSize: 13.sp,
                      height: 1.45,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 18.h),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                style: FilledButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 15.h, horizontal: 18.w),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                ),
                onPressed: () => notifier.backupCompleteJson(context),
                icon: const Icon(Icons.file_download_outlined),
                label: Text(
                  'Guardar copia JSON',
                  style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w700),
                ),
              ),
            ),
            SizedBox(height: 10.h),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 15.h, horizontal: 18.w),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  side: BorderSide(color: colors.outlineVariant),
                ),
                onPressed: () => notifier.restoreCompleteJson(context),
                icon: const Icon(Icons.settings_backup_restore_rounded),
                label: Text(
                  'Restaurar copia JSON',
                  style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
