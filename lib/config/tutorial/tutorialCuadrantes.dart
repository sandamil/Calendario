import 'package:calendario2/config/theme/my_colors.dart';
import 'package:calendario2/widgets/customText.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';
// import 'package:tutorial_coach_mark/animated_focus_light.dart';


const _info =
    "Pulsa en este boton y seleccionas la fecha de inicio de tu Cuadrante o el primer dia que quieres marcar en el calendario";
const _info2 =
    'Pulsa aqui para selecionar la fecha en la que acaba el cuadrante.';
const _info3 =
    'Se usa para marcar en el calendario,dias que finalizan en una fecha concreta, como podrian ser dias de vacaciones, bajas, permisos...';
const _info4 =
    'Activa esta opcion siempre que quieras añadir a todo el calendario un cuadrante o turno de trabajo que se repiten todo el año.\nAl activarlo, se desactiva la fecha de fin, por que automaticamente se marca en el calendario los dias por un periodo de un año.';
const _info5 =
    'El cuadrante que crees en esta pantalla se repetirá durante todo el calendario.';
const _info6 =
    'Este es un ejemplo de un Cuadrante para una persona que trabaje: \n 2 mañanas,\n 2 tardes,\n 2 noches y\n 6 dias libres.\nRecuerda que es necesario añadir los dias libres.';
const _info7 =
    'Pulsa en este botón para crear tu propio cuadrante con los dias o turnos, que tienes creados, en la pantalla Turnos.\nEste ejemplo se repetira en todo el calendario hasta la fecha que ponga en la casilla de fin. \nPuedes crear un cuadrante con los dias que quieras no hay minimo ni máximo \nVolverá a empezar por el primer día de forma automatica, el dia siguiente al ultimo de la serie que aqui se cree.\n\n CONSEJO: Puedes añadir, por ejemplo, una semana de vacaciones añadiendo aqui un solo dia de vacaciones y marcara todos los dias entre la fecha de inicio y fin que indiques.';
const _info8 =
    'Pulsa este botón para enviar el cuadrante creado al calendario y que se marquen los dias de la forma asignada.';
const _info9 =
    'Con el ejemplo dado eneste tutorial, asi se vería nuestro calendario:';

class ListTargetCuadrantes {
  ListTargetCuadrantes();


  List<TargetFocus> createTargets(keyButton, keyButton2, keyButton3,keyButton4,keyButton5) {
    List<TargetFocus> targets = [];
    targets.add(
      TargetFocus(
        identify: "Target 1",
        keyTarget: keyButton,
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
                      " Inicio de Cuadrante",
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
                          data: _info,
                          style: GoogleFonts.lato(),
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
        shape: ShapeLightFocus.RRect,
      ),
    );
    targets.add(TargetFocus(
      identify: "Target 2",
      keyTarget: keyButton2,
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
                    " Fin de Cuadrante",
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
                        data: _info2,
                        style: GoogleFonts.lato(),
                        color: Colors.white,
                        textAlign: TextAlign.center,
                        fontSize: 20.sp,
                      ),
                      CustomTextWidget(
                        data: _info3,
                        style: GoogleFonts.lato(),
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
      shape: ShapeLightFocus.RRect,
    ));
    targets.add(TargetFocus(
      identify: "Target 3",
      keyTarget: keyButton3,
      contents: [
        TargetContent(
            align: ContentAlign.bottom,
            child: Container(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text(
                    "Botón Turnos de trabajo",
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.90),
                      fontSize: 26.sp,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: CustomTextWidget(
                      data: _info4,
                      style: GoogleFonts.lato(),
                      color: Colors.white,
                      textAlign: TextAlign.center,
                      fontSize: 20.sp,
                    ),
                  ),
                  CustomTextWidget(
                    data: _info5,
                    style: GoogleFonts.lato(),
                    color: Colors.white,
                    textAlign: TextAlign.center,
                    fontSize: 20.sp,
                  ),
                ],
              ),
            )),
        TargetContent(
            align: ContentAlign.top,
            child: Container(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text(
                    "Recomendación",
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
                      data:
                      "Activa esta opción, siempre que añadas turnos de trabajo o tipos de dias a todo el calendario",
                      style: GoogleFonts.lato(),
                      color: Colors.white,
                      textAlign: TextAlign.center,
                      fontSize: 20.sp,
                    ),
                  )
                ],
              ),
            ))
      ],
      shape: ShapeLightFocus.RRect,
    ));
    targets.add(TargetFocus(
      identify: "Target 4",
      keyTarget: keyButton4,
      contents: [
        TargetContent(
            align: ContentAlign.top,
            child: Container(
              padding: EdgeInsets.only(top: 10.h),
              height: 400.h,
              child: SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.only(
                              top: 30.h, left: 2.w, right: 2.w),
                          child: Image.asset(
                            'assets/images/cuadranteTuto.png',
                            fit: BoxFit.fill,
                            width: 80.w,
                          ),
                        ),
                        Column(
                          children: <Widget>[
                            Padding(
                              padding:  EdgeInsets.only(top: 10.h),
                              child: Text(
                                "Ejemplo",
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.90),
                                  fontSize: 26.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(2.0),
                              width: 450.w,
                              child: CustomTextWidget(
                                data: _info6,
                                style: GoogleFonts.lato(),
                                color: Colors.white,
                                textAlign: TextAlign.center,
                                fontSize: 20.sp,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        "Como crear cuadrante",
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.90),
                          fontSize: 26.sp,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    CustomTextWidget(
                      data: _info7,
                      style: GoogleFonts.lato(),
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
      identify: "Target 5",
      keyTarget: keyButton5,
      contents: [
        TargetContent(
          align: ContentAlign.left,
          child: Container(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                SizedBox(
                  height: 25,
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "Publicar Cuadrante",
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
                  style: GoogleFonts.lato(),
                  color: Colors.white,
                  textAlign: TextAlign.center,
                  fontSize: 20.sp,
                ),
              ],
            ),
          ),
        ),
        TargetContent(
          align: ContentAlign.bottom,
          child: Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(top: 100.0),
                  child: Column(
                    children: <Widget>[
                      Text(
                        "Resultado",
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.90),
                          fontSize: 26.sp,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      CustomTextWidget(
                        data: _info9,
                        style: GoogleFonts.lato(),
                        color: Colors.white,
                        textAlign: TextAlign.center,
                        fontSize: 20.sp,
                      ),
                      Container(
                        child: Image.asset(
                          'assets/images/mesTuto.png',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
      shape: ShapeLightFocus.RRect,
    ));
    return targets;
  }
}
