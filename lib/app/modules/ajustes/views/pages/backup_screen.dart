import 'package:calendario2/app/data/local/calendarDatabase.dart';
import 'package:calendario2/app/data/local/taskDatabase.dart';
import 'package:calendario2/app/modules/ajustes/controllers/ajustes_controller.dart';
import 'package:calendario2/config/theme/my_colors.dart';
import 'package:calendario2/config/theme/my_fonts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:get/get.dart';

import '../../../../../widgets/buttons/buttons.dart';

class BackupScreen extends GetView<AjustesController> {
  const BackupScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: Theme.of(context).iconTheme,
        title: Text(
          'Backup',
          style: CustomTextStyle.appBarTitle(context: context),
        ),
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding:
                EdgeInsets.only(top: 15.h, bottom: 10.h, left: 8.w, right: 8.w),
            child: Text(
              'Antes de realizar una restauracion de datos:\n'
              'recuerda que es irreversible, puedes hacer todos los backup que quieras, pero si restauras los datos, los datos que tienes guardados en el calendario, o las notas, se cambiaran por las que tengas guardados en el backup, y no podras recuperar los anteriores.',
              textAlign: TextAlign.center,
              style: TextStyle(
                // color: Colors.black,
                fontSize: 16.sp,
              ),
            ),
          ),
          SizedBox(
            height: 10.h,
          ),
          Padding(
            padding:
                EdgeInsets.only(top: 1.h, bottom: 15.h, left: 8.w, right: 8.w),
            child: Text(
              'Lo primero:\n'
              'pulsa aqui para elegir donde guardar las copias de seguridad',
              textAlign: TextAlign.center,
              style: TextStyle(
                // color: Colors.black,
                fontSize: 16.sp,
              ),
            ),
          ),
          FutureBuilder<bool>(
            future: controller.isPickDirectorySupported,
            builder: (context, snapshot) {
              if (!snapshot.hasData || !snapshot.data!) return Container();
              return Padding(
                padding: EdgeInsets.only(top: 4.h, bottom: 10.h),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: MyColors.botonBgColor,
                    padding:
                        EdgeInsets.symmetric(horizontal: 30.w, vertical: 10.h),
                  ),
                  onPressed: controller.pickDirectory,
                  child: Text(
                    'Selecciona donde guardar el backup',
                    style: TextStyle(
                        fontSize: 16.sp,
                        color: MyColors.textColor,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              );
            },
          ),
          SizedBox(
            height: 10.h,
          ),
          Column(
            children: [
              Padding(
                padding: EdgeInsets.only(bottom: 10.h),
                child: const Text(
                  'Quieres hacer backup de Notas guardadas?',
                  style: TextStyle(
                      // color: Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  AppBtn(
                    minimumSize: Size(120.w, 40.h),
                    padding: EdgeInsets.all(12.h),
                    expand: true,
                    border: const BorderSide(color: Colors.black26),
                    bgColor: MyColors.botonBgColor,
                    onPressed: () async {
                      await NotasDB.instance.close();
                      controller.backupNotasDb();
                    },
                    semanticLabel: 'Backup Notas',
                    child: Text(
                      'Guardar\nNotas',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: MyColors.textColor,
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  AppBtn(
                    minimumSize: Size(120.w, 40.h),
                    padding: EdgeInsets.all(12.h),
                    expand: true,
                    border: const BorderSide(color: Colors.black26),
                    bgColor: MyColors.botonBgColor,
                    semanticLabel: 'Restaurar Notas',
                    onPressed: () async {
                      await NotasDB.instance.close();
                      controller.restoreNotasDb();
                    },
                    child: Text(
                      'Restaurar\nNotas',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: MyColors.textColor,
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(
            height: 40.h,
          ),
          Column(
            children: [
              Padding(
                padding: EdgeInsets.only(bottom: 10.h),
                child: const Text(
                  'Quieres hacer backup del Calendario?',
                  style: TextStyle(
                      // color: Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  AppBtn(
                    minimumSize: Size(120.w, 40.h),
                    padding: EdgeInsets.all(12.h),
                    expand: true,
                    border: const BorderSide(color: Colors.black26),
                    bgColor: MyColors.botonBgColor,
                    semanticLabel: 'Backup Calendario',
                    onPressed: () async {
                      await controller.backupCalendarioDb();
                    },
                    child: Text(
                      'Guardar\nCalendario',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: MyColors.textColor,
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  AppBtn(
                    minimumSize: Size(120.w, 40.h),
                    padding: EdgeInsets.all(12.h),
                    expand: true,
                    border: const BorderSide(color: Colors.black26),
                    bgColor: MyColors.botonBgColor,
                    semanticLabel: 'Restaurar Calendario',
                    onPressed: () async {
                      await controller.restoreCalendarioDb();
                    },
                    child: Text(
                      'Restaurar\nCalendario',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: MyColors.textColor,
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
