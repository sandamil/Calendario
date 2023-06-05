import 'dart:ui';

import 'package:calendario2/config/theme/my_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:get/get.dart';
import 'package:introduction_screen/introduction_screen.dart';

import '../../../../config/theme/my_fonts.dart';
import '../../../../config/theme/styles.dart';
import '../../../../config/util/constant.dart';
import '../../../data/local/app_storage.dart';
import '../controllers/boarding_controller.dart';

class BoardingView extends GetView<BoardingController> {
  static BoardingController sx =
      Get.put(BoardingController()); // Instantiate Get Controller, *in* build()

  BoardingView({Key? key}) : super(key: key);

  final List<PageViewModel> listPagesViewModel = [
    PageViewModel(
      decoration: pageDecoration,
      title: 'Calendario 2.0',
      body: "Bienvenidos a la aplicación\n\n"
          "En esta app podrás llevar un control de tus turnos y horarios de trabajo y anotar todo lo que necesites."
          "\n\nPonte en contacto con nosotros ante cualquier duda o sugerencia.\nANTES DE UNA VALORACION NEGATIVA CONTACTA CON NOSOTROS¡\nResolveremos cualquier problema."
          "\n\nAntes de nada, si vienes de una versión anterior de esta aplicación, puedes acceder a los datos guardados desde la pantalla principal o desde el menu ayuda/version anterior."
          "\n\nSi te gusta más la Versión anterior, tambien la puedes descargar desde esa pantalla del menu."
          "\n\nEste tutorial solo se verá la primera vez que inicies la aplicacion, "
          "si tienes dudas, puedes ir desde menú, a la pantalla ayuda,"
          " donde podrás ver este tutorial "
          "y también a un monton de videotutoriales, en los que ver como usar cualquier función de la aplicación"
          "\n\nVamos a empezar, "
          "\n¡Desliza la pantalla hacia la izquierda!",
    ),
    PageViewModel(
      decoration: pageDecoration,
      title: 'Tutorial',
      body: "Como usar la app:\n\n"
          "Para marcar los días que trabajas o que quieres resaltar, en el calendario, tenemos que crear primero los tipos de días que queremos añadir."
          "\n\nDesde el botón de menú accedemos a la pantalla de Turnos, y aquí creamos los tipos de día, o turnos que vamos a usar de forma predefinida."
          "\nPuedes crear diferentes tipos de día, si trabajas de mañanas, tardes y noches, ya están creados y puedes usarlos. podrías añadir otros como Vacaciones, Baja, Partido... "
          "\nLo que necesites "
          "\nEstos son los días que vas a poder elegir para crear tu cuadrante, y también para añadir al calendario al mantener pulsado sobre cualquier día."
          "\nEn la siguiente pantalla tienes video explicativo",
    ),
    PageViewModel(
      decoration: pageDecorationFullScreen,
      title: "",
      body: "",
      image: Image.asset(
        'assets/other/turnos.gif',
      ),
      // bodyWidget: const Center(
      //   child: Padding(
      //     padding: EdgeInsets.all(16.0),
      //     child: Text(
      //       'You can track your progress through the calendar view in every habit or on the statistics page.',
      //       textAlign: TextAlign.center,
      //       style: TextStyle(fontSize: 18),
      //     ),
      //   ),
      // ),boar
    ),
    PageViewModel(
      decoration: pageDecoration,
      title: 'Cuadrantes',
      body: "Vamos a verlos:\n\n"
          "Desde el menú cuadrante, creas una lista de días para un turno completo que se repetirá en el calendario."
          "\nSi tu turno, por ejemplo, se repite cada 10 días, tienes que hacer una lista con esos 10 días."
          "\n\nCuando tengas el listado de días hecho, añades la fecha de inicio, esta es la fecha en la que se añadirá el primer día del cuadrante o lista que acabas de crear"
          "\nLa fecha de fin es la fecha en la que quieres que se dejen de marcar los días en el calendario, solo indica el ultimo día del calendario que se marcara con ese cuadrante. por defecto se añade un año, si no la cambias"
          "\nTambién puedes crear una lista con solo un día, para marcar varios dias del calendario. Esto es util por ejemplo para marcar 15 dias de vacaciones en el calendario."
          "\nEn la siguiente pantalla lo veras en un video.",
    ),
    PageViewModel(
      decoration: pageDecorationFullScreen,

      title: "",
      body: "",
      image: Image.asset(
        'assets/other/Cuadrantes.gif',
      ),
      // bodyWidget: const Center(
      //   child: Padding(
      //     padding: EdgeInsets.all(16.0),
      //     child: Text(
      //       'You can track your progress through the calendar view in every habit or on the statistics page.',
      //       textAlign: TextAlign.center,
      //       style: TextStyle(fontSize: 18),
      //     ),
      //   ),
      // ),boar
    ),
    PageViewModel(
      decoration: pageDecoration,
      title: 'Notas',
      body: "No te olvides nada:\n\n"
          "Desde el menú puedes acceder a la pantalla Notas, donde puedes crear y gestionar las notas y tareas pendientes o completadas"
          "\nPodrás añadir tantas como desees al día seleccionado, las puedes borrar y editar, también desde la pantalla principal pulsando o deslizando la nota debajo del calendario, donde se muestran las notas para el día seleccionado."
          "\nEn la pantalla notas tienes un buscador por si necesitas buscar una o varias notas entre todas las guardadas y así poder consultarla o editarla de forma rápida."
          "\nTambién tiene un botón donde filtraras y se mostraran solo las marcadas como importantes si esta activado o todas si no lo esta."
          "\nA todas las notas le puedes añadir alarma para que te avise en el momento que hayas seleccionado la hora de inicio o el que elijas, ya que puedes personalizar el aviso a la hora que necesites, antes de la hora de inicio"
          "\nAhora vas a ver todo esto en un video",
    ),
    PageViewModel(
      decoration: pageDecorationFullScreen,

      title: "",
      body: "",
      image: Image.asset(
        'assets/other/Notas.gif',
      ),
      // bodyWidget: const Center(
      //   child: Padding(
      //     padding: EdgeInsets.all(16.0),
      //     child: Text(
      //       'You can track your progress through the calendar view in every habit or on the statistics page.',
      //       textAlign: TextAlign.center,
      //       style: TextStyle(fontSize: 18),
      //     ),
      //   ),
      // ),boar
    ),
    PageViewModel(
      decoration: PageDecoration(
        imageFlex: 2,
        footerFlex: 0,
        titleTextStyle: TextStyle(fontSize: 25.sp),
        titlePadding: EdgeInsets.only(top: 16.h, bottom: 14.h),
        bodyTextStyle: TextStyle(
          fontWeight: FontWeight.w400,
          fontSize: 18.w,
        ),
        // pageColor: Colors.white,
        imagePadding: EdgeInsets.only(top: 36.h, bottom: 4.h),
      ),
      title: "Configuracion",
      body:
          "Antes de empezar vamos a elegir el tema de la aplicacion, prefieres oscuro, o claro.",
      image: Obx(
        () => sx.on.value
            ? Image.asset(
                'assets/other/oscuro.png',
              )
            : Image.asset(
                'assets/other/claro.png',
              ),
      ),

      footer: Column(
        children: [
          ListTile(
            title:
                Obx(() => Text('Pulsa para cambiar a tema: ${sx.temaString}')),
            trailing: Obx(
              () => Switch(onChanged: (val) => sx.toggle(), value: sx.on.value),
            ),
          ),
        ],
      ),
      // bodyWidget: const Center(
      //   child: Padding(
      //     padding: EdgeInsets.all(16.0),
      //     child: Text(
      //       'You can track your progress through the calendar view in every habit or on the statistics page.',
      //       textAlign: TextAlign.center,
      //       style: TextStyle(fontSize: 18),
      //     ),
      //   ),
      // ),boar
    )
  ];

  @override
  Widget build(BuildContext context) {
    TextStyle bodyStyle = TextStyle(fontSize: 19.0, color: Colors.black);
    PageDecoration pageDecoration = const PageDecoration(
      titleTextStyle: TextStyle(
        fontSize: 28.0,
        fontWeight: FontWeight.w700,
        color: Colors.black,
      ),
      // bodyTextStyle: bodyStyle,
      bodyPadding: EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
      pageColor: Colors.white,
      // imagePadding: EdgeInsets.zero,
    );

    return IntroductionScreen(
      dotsDecorator: const DotsDecorator(
        size: Size(10, 10),
        activeSize: Size(40, 10),
        color: PRIMARY_COLOR_TRANSPARENTE,
        activeColor: PRIMARY_COLOR,
        activeShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(25)),
        ),
      ),
      dotsContainerDecorator: const ShapeDecoration(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
      ),
      curve: Curves.fastLinearToSlowEaseIn,
      skipOrBackFlex: 0,
      nextFlex: 0,
      controlsPadding: const EdgeInsets.all(10.0),
      pages: listPagesViewModel,
      done: const Text("OK", style: TextStyle(fontWeight: FontWeight.w600)),
      onDone: () {
        AppStorage.write(
          key: APP_FIRST_TIME_OPEN,
          value: 'true',
        );
        // calendarController.onInit();
        Get.toNamed('/home');
        // if (Provider.of<SettingsManager>(context, listen: false)
        //     .getSeenOnboarding) {
        //   Navigator.pop(context);
        // } else {
        //   Provider.of<SettingsManager>(context, listen: false)
        //       .setSeenOnboarding = true;
        // }
      },
      next: const Icon(Icons.arrow_forward),
      showSkipButton: true,
      skip: const Text("Saltar"),
    );
  }
}
