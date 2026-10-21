import 'package:calendario2/app/modules/ajustes/providers/ajustes_provider.dart';
import 'package:calendario2/config/theme/my_colors.dart';
import 'package:calendario2/config/theme/my_fonts.dart';
import 'package:calendario2/widgets/buttons/buttons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class BackupScreen extends ConsumerWidget {
  const BackupScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(ajustesProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        iconTheme: Theme.of(context).iconTheme,
        title: Text(
          'Backup',
          style: CustomTextStyle.appBarTitle(context: context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(12.w),
              child: Text(
                'Antes de restaurar datos, recuerda que la operación '
                'reemplaza los datos actuales del calendario o de las notas. '
                'Haz una copia de seguridad antes de continuar.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16.sp),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(12.w),
              child: Text(
                'Primero selecciona dónde guardar las copias de seguridad.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16.sp),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 12.w,
                vertical: 10.h,
              ),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: MyColors.botonBgColor,
                    padding: EdgeInsets.symmetric(
                      horizontal: 20.w,
                      vertical: 14.h,
                    ),
                  ),
                  onPressed: () => notifier.backupCompleteJson(context),
                  icon: Icon(
                    Icons.save_alt,
                    color: MyColors.textColor,
                  ),
                  label: Text(
                    'Guardar copia completa (JSON)',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: MyColors.textColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            FutureBuilder<bool>(
              future: notifier.isPickDirectorySupported,
              builder: (context, snapshot) {
                if (snapshot.data != true) return const SizedBox.shrink();

                return Padding(
                  padding: EdgeInsets.symmetric(vertical: 10.h),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: MyColors.botonBgColor,
                      padding: EdgeInsets.symmetric(
                        horizontal: 30.w,
                        vertical: 10.h,
                      ),
                    ),
                    onPressed: notifier.pickDirectory,
                    child: Text(
                      'Selecciona donde guardar el backup',
                      style: TextStyle(
                        fontSize: 16.sp,
                        color: MyColors.textColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              },
            ),
            SizedBox(height: 12.h),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 12.w,
                vertical: 10.h,
              ),
              child: AppBtn(
                minimumSize: Size(120.w, 40.h),
                padding: EdgeInsets.all(12.h),
                expand: true,
                border: BorderSide(
                  color: Theme.of(context).dividerColor,
                ),
                bgColor: MyColors.botonBgColor,
                semanticLabel: 'Restaurar copia completa',
                onPressed: () => notifier.restoreCompleteJson(context),
                child: Text(
                  'Restaurar copia completa',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: MyColors.textColor,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const _BackupSection(
                title: 'Quieres hacer backup de Notas guardadas?'),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                AppBtn(
                  minimumSize: Size(120.w, 40.h),
                  padding: EdgeInsets.all(12.h),
                  expand: true,
                  border: BorderSide(color: Theme.of(context).dividerColor),
                  bgColor: MyColors.botonBgColor,
                  semanticLabel: 'Backup Notas',
                  onPressed: () => notifier.backupNotasDb(context),
                  child: Text(
                    'Guardar\nNotas',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: MyColors.textColor,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                AppBtn(
                  minimumSize: Size(120.w, 40.h),
                  padding: EdgeInsets.all(12.h),
                  expand: true,
                  border: BorderSide(color: Theme.of(context).dividerColor),
                  bgColor: MyColors.botonBgColor,
                  semanticLabel: 'Restaurar Notas',
                  onPressed: notifier.restoreNotasDb,
                  child: Text(
                    'Restaurar\nNotas',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: MyColors.textColor,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 36.h),
            const _BackupSection(title: 'Quieres hacer backup del Calendario?'),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                AppBtn(
                  minimumSize: Size(120.w, 40.h),
                  padding: EdgeInsets.all(12.h),
                  expand: true,
                  border: BorderSide(color: Theme.of(context).dividerColor),
                  bgColor: MyColors.botonBgColor,
                  semanticLabel: 'Backup Calendario',
                  onPressed: () => notifier.backupCalendarioDb(context),
                  child: Text(
                    'Guardar\nCalendario',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: MyColors.textColor,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                AppBtn(
                  minimumSize: Size(120.w, 40.h),
                  padding: EdgeInsets.all(12.h),
                  expand: true,
                  border: BorderSide(color: Theme.of(context).dividerColor),
                  bgColor: MyColors.botonBgColor,
                  semanticLabel: 'Restaurar Calendario',
                  onPressed: notifier.restoreCalendarioDb,
                  child: Text(
                    'Restaurar\nCalendario',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: MyColors.textColor,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 24.h),
          ],
        ),
      ),
    );
  }
}

class _BackupSection extends StatelessWidget {
  final String title;

  const _BackupSection({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: Text(
        title,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
