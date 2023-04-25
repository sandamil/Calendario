import 'package:calendario2/config/theme/my_colors.dart';
import 'package:calendario2/widgets/customText.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
// import 'package:tutorial_coach_mark/animated_focus_light.dart';


const _info =
    "Pulsa en este boton y seleccionas la fecha de inicio de tu Cuadrante o el primer dia que quieres marcar en el calendario";
const _info2 =
    'Pulsa aqui para selecionar la fecha en la que acaba el cuadrante.';
const _info3 =
    'Se usa para marcar en el calendario,dias que finalizan en una fecha concreta, como podrian ser dias de vacaciones, bajas, permisos...'
    '\n\nPor defecto se estable un año de cuadrante pero puedes elegir la fecha en que se deja de marcar este listado en el calendario';
const _info4 =
    'Si tu turno fuese Mañana-Tarde y dos dias libres, por ejemplo, añadirias aquí una mañana una tarde y dos días libres, nada más, si siempre se repite ese turno'
    '\nLa fecha de inicio deberias poner cualquiera en la que trabajes o hayas trabajado de mañana, y apartir de ahi se marcarian todos los días, durante un año, si no cambias fecha de fin';
const _info5 =
    'El cuadrante que crees en esta pantalla se repetirá durante todo el calendario.';
const _info6 =
    'Este es un ejemplo de un Cuadrante para una persona que trabaje: \n 2 mañanas,\n 2 tardes,\n 2 noches y\n 6 dias libres.\nRecuerda que es necesario añadir los dias libres.';
const _info7 =
    'Pulsa en este botón para crear tu propio cuadrante con los dias o turnos, que tienes creados, en la pantalla Turnos.\nEste ejemplo se repetira en todo el calendario hasta la fecha que ponga en la casilla de fin. \nPuedes crear un cuadrante con los dias que quieras no hay minimo ni máximo \nVolverá a empezar por el primer día de forma automatica, el dia siguiente al ultimo de la serie que aqui se cree.\n\n CONSEJO: Puedes añadir, por ejemplo, una semana de vacaciones añadiendo aqui un solo dia de vacaciones y marcara todos los dias entre la fecha de inicio y fin que indiques.';
const _info8 =
    'Pulsa este botón para enviar el cuadrante creado al calendario y que se marquen los dias de la forma asignada.';
const _info9 =
    'Con el ejemplo dado en este tutorial, asi se vería nuestro calendario, si empezásemos, el dia 1 del mes, la primera mañana:';


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
      ),
    );
    targets.add(TargetFocus(
      identify: "Target 2",
      keyTarget: keyButton2,
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
                  "Fin de Cuadrante",
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
                      // style: GoogleFonts.lato(),
                      color: Colors.white,
                      textAlign: TextAlign.center,
                      fontSize: 20.sp,
                    ),
                    CustomTextWidget(
                      data: _info3,
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
      identify: "Target 3",
      keyTarget: keyButton3,
      contents: [
        TargetContent(
            align: ContentAlign.bottom,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Text(
                  "Turnos de trabajo",
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
                    // style: GoogleFonts.lato(),
                    color: Colors.white,
                    textAlign: TextAlign.center,
                    fontSize: 20.sp,
                  ),
                ),
                CustomTextWidget(
                  data: _info5,
                  // style: GoogleFonts.lato(),
                  color: Colors.white,
                  textAlign: TextAlign.center,
                  fontSize: 20.sp,
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
                        "Si creas un cuadrante para tu turno de trabajo, pon la fecha de inicio el dia que empiezas el ciclo o los turnos, no dejes la de hoy",
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
      identify: "Target 4",
      keyTarget: keyButton4,
      contents: [
        TargetContent(
            align: ContentAlign.top,
            child: Container(
              padding: EdgeInsets.only(top: 10.h),
              height: 700.h,
              child: SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Padding(
                          padding:
                              EdgeInsets.only(top: 50.h, left: 2.w, right: 2.w),
                          child: Image.asset(
                            'assets/images/cuadranteTuto.png',
                            fit: BoxFit.fill,
                            width: 130.w,
                          ),
                        ),
                        Column(
                          children: <Widget>[
                            Padding(
                              padding: EdgeInsets.only(top: 40.h),
                              child: Text(
                                "Ejemplo",
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.90),
                                  fontSize: 20.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(2.0),
                              width: 200.w,
                              child: CustomTextWidget(
                                data: _info6,
                                // style: GoogleFonts.lato(),
                                color: Colors.white,
                                textAlign: TextAlign.center,
                                fontSize: 16.sp,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(
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
                      // style: GoogleFonts.lato(),
                      color: Colors.white,
                      textAlign: TextAlign.center,
                      fontSize: 18.sp,
                    ),
                  ],
                ),
              ),
            ))
      ],
      shape: ShapeLightFocus.Circle,
    ));
    targets.add(TargetFocus(
      identify: "Target 5",
      keyTarget: keyButton5,
      contents: [
        TargetContent(
          align: ContentAlign.left,
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
                      // style: GoogleFonts.lato(),
                      color: Colors.white,
                      textAlign: TextAlign.center,
                      fontSize: 20.sp,
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 8.h),
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
      ],
      shape: ShapeLightFocus.Circle,
    ));
    return targets;
  }
}
