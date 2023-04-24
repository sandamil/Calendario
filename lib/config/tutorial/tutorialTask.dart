import 'package:calendario2/config/util/assets.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:calendario2/config/theme/my_colors.dart';
import 'package:calendario2/widgets/customText.dart';

const _info = "Pantalla Notas";
const _info2 =
    "En esta pantalla aparecerán todas las notas que tienes guardadas en el calendario. "
    "\n Si pulsas en cada una de las notas te llevara a una pantalla con todo su contenido."
    "\n Deslizando hacia la izquierda, aparecerán varias funciones rápidas"
    "\nAdemás de añadir notas desde la pantalla de inicio, también las podras añadir desde aquí, pulsando en el botón de la parte inferior derecha";
const _info3 = "Filtro para notas Importantes";
const _info4 =
    "Pulsa en este botón para que solamente se muestren las notas que hayas guardado como importantes, "
    "si no has guardado una nota como importante también la puedes modificar después para que aparezca como importante, editando la nota.";
const _info5 = "Botón búsqueda";
const _info6 =
    "Desde aquí podrás buscar la nota que quieras entre todas las guardadas, escribiendo el titulo o parte del título guardado, filtrará las que tengan ese mismo nombre.";
const _info7 = "Tutorial ayuda";
const _info8 =
    "Puedes pulsar este botón si en algún momento quieres volver a verlo.";
const _info9 =
    "Este tutorial solo se vera de forma automática la primera vez que abres esta pantalla tras la instalación de la app.";



class ListTargetTask {
  ListTargetTask();

  List<TargetFocus> createTargets(
      keyButton10, keyButton11, keyButton12, keyNotasListAyuda) {
    List<TargetFocus> targets = [];
    targets.add(
      TargetFocus(
        identify: "Target 1",
        keyTarget: keyButton10,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            child: Container(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Container(
                    child: Image.asset(
                      AppAsset.imageTutorial('Notas1.png'),
                    ),
                  ),
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
      identify: "Target 11",
      keyTarget: keyButton11,
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
                        data:_info4,
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
      shape: ShapeLightFocus.RRect,
    ));
    targets.add(TargetFocus(
      identify: "Target 12",
      keyTarget: keyButton12,
      contents: [
        TargetContent(
            align: ContentAlign.bottom,
            child: Container(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text(
                    _info5,
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
                      data:_info6,
                      // style: GoogleFonts.lato(),
                      color: Colors.white,
                      textAlign: TextAlign.center,
                      fontSize: 20.sp,
                    ),
                  ),
                ],
              ),
            )),
      ],
      shape: ShapeLightFocus.RRect,
    ));
    targets.add(TargetFocus(
      identify: "Target NotasListAyuda",
      keyTarget: keyNotasListAyuda,
      shape: ShapeLightFocus.Circle,
      contents: [
        TargetContent(
            align: ContentAlign.left,
            child: Container(
              padding: EdgeInsets.only(top: 26.h),
              child: Text(
                _info7,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.90),
                  fontSize: 26.sp,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            )),
        TargetContent(
          align: ContentAlign.bottom,
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
                  child: CustomTextWidget(
                    data: _info8,
                    color: Colors.white,
                    textAlign: TextAlign.center,
                    fontSize: 20.sp,
                  ),
                ),
                CustomTextWidget(
                  data: _info9,
                  style: TextStyle(),
                  color: Colors.white,
                  textAlign: TextAlign.center,
                  fontSize: 20.sp,
                ),
              ],
            ),
          ),
        ),
      ],
    ));

    return targets;
  }
}
