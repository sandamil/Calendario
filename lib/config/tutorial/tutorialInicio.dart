import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:calendario2/widgets/customText.dart';

const _info = "Botón menú:";
const _info2 =
    "Desde este botón accedes al menú de la aplicación donde podrás acceder al menú, "
    "desde donde podrás ir a las diferentes utilidades de la app y ajustes";
const _info3 = "Botón HOY";
const _info4 = "Pulsa en este botón para ir al dia de hoy."
    "\n \n Si cambias de mes para ver tu calendario y quieres volver de forma rapida al dia de hoy, "
    "esta es la opcion mas rapida y cómoda";
const _info5 = "Calendario";
const _info6 =
    "En el calendario aparecen los turnos de tu cuadrante creado y las notas guardadas."
    "\nPusando en cada dia veras debajo las notas para ese dia"
    "\nSi mantienes pulsado encima de algun dia podrás aladir de forma rapida un turno o una nota";
const _info7 = "Resumen de dia";
const _info8 =
    "Aqui aparecerean las notas guardadas, cuando selecciones algun dia del calendario, si has añadido alguna.";
const _info9 =
    "Pulsando en cada nota te llevara a una pantalla con toda la informacion de esta y donde la podrás editar."
    "\n\nSi deslizas la nota hacia la derecha aparecerán varias funciones rápidas.";


class InicioListTarget {
  InicioListTarget();

  List<TargetFocus> createTargets(
      calKeys1, calKeys2, calKeys3, calKeys4) {
    List<TargetFocus> targets = [];
    targets.add(
      TargetFocus(
        identify: "Target 6",
        keyTarget: calKeys1,
        shape: ShapeLightFocus.Circle,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            child: Container(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  SizedBox(
                    height: 2.h,
                  ),
                  Padding(
                    padding: EdgeInsets.all(1.h),
                    child: Text(
                      _info,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.90),
                        fontSize: 26.sp,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(2.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        SizedBox(
                          height: 2.h,
                        ),
                        CustomTextWidget(
                          data: _info2,
                          // style: GoogleFonts.lato(),
                          color: Colors.white,
                          textAlign: TextAlign.center,
                          fontSize: 20.sp,
                        ),
                        // CustomTextWidget(
                        //   data:
                        //       "Si mantienes pulsado cualquier dia del calendario aparecera tambien un meno para añadir notas o cuando los tengas creados, cambiar el tipo de turno o dia para la fecha donde mantienes pulsado.",
                        //   style: GoogleFonts.lato(),
                        //   color: Colors.white,
                        //   textAlign: TextAlign.center,
                        //   fontSize: 20.sp,
                        // ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
    targets.add(TargetFocus(
      identify: "Target 2",
      keyTarget: calKeys2,
      contents: [
        TargetContent(
          align: ContentAlign.bottom,
          child: Container(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                SizedBox(
                  height: 2.h,
                ),
                Padding(
                  padding: EdgeInsets.all(1.h),
                  child: Text(
                    _info3,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.90),
                      fontSize: 26.sp,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(2.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      SizedBox(
                        height: 2.h,
                      ),
                      CustomTextWidget(
                        data: _info4,
                        // style: GoogleFonts.lato(),
                        color: Colors.white,
                        textAlign: TextAlign.center,
                        fontSize: 20.sp,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
      shape: ShapeLightFocus.Circle,
    ));
    targets.add(TargetFocus(
      identify: "Target 3",
      keyTarget: calKeys3,
      contents: [
        TargetContent(
            align: ContentAlign.top,
            child: Text(
              _info5,
              style: TextStyle(
                color: Colors.white.withOpacity(0.90),
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            )),
        TargetContent(
            align: ContentAlign.bottom,
            child: SingleChildScrollView(
              child: Container(
                height: 200.h,
                child: CustomTextWidget(
                  data: _info6,
                  // style: GoogleFonts.lato(),
                  color: Colors.white,
                  textAlign: TextAlign.center,
                  fontSize: 18.sp,
                ),
              ),
            )),
      ],
      shape: ShapeLightFocus.RRect,
    ));
    targets.add(TargetFocus(
      identify: "Target 4",
      keyTarget: calKeys4,
      contents: [
        TargetContent(
            align: ContentAlign.top,
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(
                      bottom: 14.h,
                    ),
                    child: Text(
                      _info7,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.90),
                        fontSize: 26.sp,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  CustomTextWidget(
                    data: _info8,
                    // style: GoogleFonts.lato(),
                    color: Colors.white,
                    textAlign: TextAlign.center,
                    fontSize: 20.sp,
                  ),
                  CustomTextWidget(
                    data: _info9,
                    // style: GoogleFonts.lato(),
                    color: Colors.white,
                    textAlign: TextAlign.center,
                    fontSize: 20.sp,
                  ),
                ],
              ),
            )),
      ],
      shape: ShapeLightFocus.RRect,
    ));

    return targets;
  }
}
