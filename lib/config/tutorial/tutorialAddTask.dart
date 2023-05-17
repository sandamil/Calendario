import 'package:flutter/material.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:calendario2/config/theme/my_colors.dart';
import 'package:calendario2/widgets/customText.dart';

const _info = "Título del evento";
const _info2 = "Aquí añades el título de la nota que quieras guardar. "
    "\n\n Es importante, por qué, este título se mostrara en la pantalla de inicio de calendario el día que lo guardes y también en la pantalla donde se muestran todas las notas."
    "\n\nTambién será el utilizado a la hora de buscar una nota, entre todas las guardadas, con el motor de búsqueda de la app";
const _info3 = "Hora de Inicio y de Fin";
const _info4 = "Marca la fecha y hora en la que quieres que se guarde la nota";
const _info5 = "La hora de inicio también será la predeterminada "
    "si decides poner alarma en el siguiente paso, lo podrás modificar despues.";
const _info6 = "Recordatorio";
const _info7 =
    "Aqui puedes elegir cuando quieres que te avise la aplicación de tu nota, o si quieres que no te avise."
    "\nSi activas recordatorio te mostrara debajo la hora y pulsando en ella puedes editar las opciones y hora";
const _info8 = "Recuerda:";
const _info9 =
    "Esta opción, no es una alarma en sí, te llegará una notificación al movil "
    "y al abrirla sonará si tienes activado el sonido"
    "\n para que esta opción funcione, "
    "no cierres la aplicación desde el gestor de aplicaciones de tu movil, déjala en segundo plano";
const _info10 = "Marcar como importante";
const _info11 =
    "Marca como importante la nota deseada, esta opción además de marcar como importante una nota, sirve para filtrar en el listado de notas solo las importantes";
const _info12 = "Ubicación y observaciones";
const _info13 = "En estos dos campos puedes insertar el texto que necesites."
    "\nEn el de ubicación se recomienda un texto corto como un lugar o ubicacion.";
const _info14 =
    "En observaciones puedes escribir un resumen o texto más amplio, se mostrará en el detalle de la nota, "
    "tanto si la abres desde la pantalla principal como desde el listado de notas";
const _info15 = "Tutorial ayuda";
const _info16 =
    "Este tutorial solo se vera de forma automática la primera vez que abres esta pantalla tras la instalación de la app.";
const _info17 =
    "Puedes pulsar este botón si en algún momento quieres volver a verlo.";


class ListTargetAddTask {
  ListTargetAddTask();

  List<TargetFocus> createTargets(keyButton13, keyButton14, keyButton15,
      keyButton16, keyButton17, keyNotasAyuda) {
    List<TargetFocus> targets = [];
    targets.add(
      TargetFocus(
        identify: "Target 13",
        keyTarget: keyButton13,
        contents: [
          TargetContent(
            align: ContentAlign.top,
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
                      fontSize: 25.sp,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
          TargetContent(
            align: ContentAlign.bottom,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                SizedBox(
                  height: 2.h,
                ),
                Padding(
                  padding: EdgeInsets.all(2.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      CustomTextWidget(
                        data: _info2,
                        // style: GoogleFonts.lato(),
                        color: Colors.white,
                        textAlign: TextAlign.center,
                        fontSize: 19.sp,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

        ],
        shape: ShapeLightFocus.RRect,
      ),
    );
    targets.add(TargetFocus(
      identify: "Target 14",
      keyTarget: keyButton14,
      contents: [
        TargetContent(
          align: ContentAlign.bottom,
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
                    CustomTextWidget(
                      data: _info5,
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
      ],
      shape: ShapeLightFocus.RRect,
    ));
    targets.add(TargetFocus(
      identify: "Target 15",
      keyTarget: keyButton15,
      contents: [
        TargetContent(
            align: ContentAlign.bottom,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Text(
                  _info6,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.90),
                    fontSize: 26.sp,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                Padding(
                  padding: EdgeInsets.only(top: 5.h),
                  child: CustomTextWidget(
                    data: _info7,
                    // style: GoogleFonts.lato(),
                    color: Colors.white,
                    textAlign: TextAlign.center,
                    fontSize: 18.sp,
                  ),
                ),
              ],
            )),
        TargetContent(
            align: ContentAlign.top,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Text(
                  _info8,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: ACCENT_COLOR,
                    fontSize: 26.sp,
                  ),
                  textAlign: TextAlign.start,
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 0.0),
                  child: CustomTextWidget(
                    data: _info9,
                    // style: GoogleFonts.lato(),
                    color: Colors.white,
                    textAlign: TextAlign.center,
                    fontSize: 20.sp,
                  ),
                )
              ],
            ))
      ],
      shape: ShapeLightFocus.RRect,
    ));
    targets.add(TargetFocus(
      identify: "Target 16",
      keyTarget: keyButton16,
      contents: [
        TargetContent(
            align: ContentAlign.top,
            child: Container(
              padding: const EdgeInsets.only(top: 10.0),
              height: 290.h,
              child: SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        _info10,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.90),
                          fontSize: 26.sp,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    CustomTextWidget(
                      data: _info11,
                      // style: GoogleFonts.lato(),
                      color: Colors.white,
                      textAlign: TextAlign.center,
                      fontSize: 20.sp,
                    ),
                  ],
                ),
              ),
            ))
      ],
      shape: ShapeLightFocus.RRect,
    ));
    targets.add(TargetFocus(
      identify: "Target 17",
      keyTarget: keyButton17,
      contents: [
        TargetContent(
          align: ContentAlign.top,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              const SizedBox(
                height: 25,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  _info12,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.90),
                    fontSize: 26.sp,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              CustomTextWidget(
                data: _info13,
                // style: GoogleFonts.lato(),
                color: Colors.white,
                textAlign: TextAlign.center,
                fontSize: 20.sp,
              ),
            ],
          ),
        ),
        TargetContent(
          align: ContentAlign.bottom,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(top: 1.h),
                child: CustomTextWidget(
                  data: _info14,
                  // style: GoogleFonts.lato(),
                  color: Colors.white,
                  textAlign: TextAlign.center,
                  fontSize: 20.sp,
                ),
              ),
            ],
          ),
        ),
      ],
      shape: ShapeLightFocus.RRect,
    ));
    targets.add(TargetFocus(
      identify: "Target NotasAyuda",
      keyTarget: keyNotasAyuda,
      contents: [
        TargetContent(
          align: ContentAlign.top,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              const SizedBox(
                height: 25,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  _info15,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.90),
                    fontSize: 26.sp,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              CustomTextWidget(
                data: _info16,
                // style: GoogleFonts.lato(),
                color: Colors.white,
                textAlign: TextAlign.center,
                fontSize: 20.sp,
              ),
            ],
          ),
        ),
        TargetContent(
          align: ContentAlign.left,
          child: CustomTextWidget(
            data: _info17,
            // style: GoogleFonts.lato(),
            color: Colors.white,
            textAlign: TextAlign.center,
            fontSize: 20.sp,
          ),
        ),
      ],
      shape: ShapeLightFocus.Circle,
    ));
    return targets;
  }
}
