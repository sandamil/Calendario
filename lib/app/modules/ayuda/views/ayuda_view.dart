import 'package:calendario2/widgets/customText.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../controllers/ayuda_controller.dart';

class AyudaView extends GetView<AyudaController> {
  const AyudaView({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AyudaView'),
        centerTitle: true,
      ),
      body:  Container(
        padding: EdgeInsets.only(top: 10.h),
        height: 700.h,
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
                      width: 160.w,
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
                          style: GoogleFonts.lato(),
                          color: Colors.white,
                          textAlign: TextAlign.center,
                          fontSize: 16.sp,
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
      )
    );
  }
}

const _info6 =
    'Este es un ejemplo de un Cuadrante para una persona que trabaje: \n 2 mañanas,\n 2 tardes,\n 2 noches y\n 6 dias libres.\nRecuerda que es necesario añadir los dias libres.';
const _info7 =
    'Pulsa en este botón para crear tu propio cuadrante con los dias o turnos, que tienes creados, en la pantalla Turnos.\nEste ejemplo se repetira en todo el calendario hasta la fecha que ponga en la casilla de fin. \nPuedes crear un cuadrante con los dias que quieras no hay minimo ni máximo \nVolverá a empezar por el primer día de forma automatica, el dia siguiente al ultimo de la serie que aqui se cree.\n\n CONSEJO: Puedes añadir, por ejemplo, una semana de vacaciones añadiendo aqui un solo dia de vacaciones y marcara todos los dias entre la fecha de inicio y fin que indiques.';
const _info8 =
    'Pulsa este botón para enviar el cuadrante creado al calendario y que se marquen los dias de la forma asignada.';
const _info9 =
    'Con el ejemplo dado eneste tutorial, asi se vería nuestro calendario:';
