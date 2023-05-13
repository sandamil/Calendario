import 'package:calendario2/app/data/local/app_storage.dart';
import 'package:calendario2/app/data/model/boarding_model.dart';
import 'package:calendario2/config/util/constant.dart';
import 'package:calendario2/config/util/transformer_page_view/index_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BoardingController extends GetxController {
  // CalendarController calendarController = Get.put(CalendarController());

  static bool boarding = true;
  final _currentPage = 0.0.obs;
  late final PageController pageController;
  late final IndexController tController;
  final List<BoardingModel> info = List<BoardingModel>.empty(growable: true);

  double get currentPage => _currentPage.value;

  @override
  void onInit() {
    super.onInit();
    pageController = PageController(initialPage: 0);
    tController = IndexController();
    pageController.addListener(() {
      _currentPage.value = pageController.page!;
    });
    info.addAll([
      const BoardingModel(
          title: 'Calendario 2.0',
          subTitle: 'Bienvenidos a la aplicación',
          description:
              "En esta app podrás llevar un control de tus turnos y horarios de trabajo y anotar todo lo que necesites."
              "\n\nPonte en contacto con nosotros ante cualquier duda o sugerencia."
              "\n\nVamos a empezar, "
              "\n¡Desliza la pantalla hacia la izquierda!",
          imagePath: 'assets/other/vacio.png'),
      const BoardingModel(
          title: 'Un pequeño tutorial',
          subTitle: 'Como usar la app:',
          description:
              "Para marcar los días que trabajas o que quieres resaltar, en el calendario, tenemos que crear primero los tipos de días que queremos añadir."
                  "\n\nDesde el botón de menú accedemos a la pantalla de Turnos, y aquí creamos los tipos de día, o turnos que vamos a usar de forma predefinida."
                  "\nPuedes crear diferentes tipos de día, si trabajas de mañanas, tardes y noches, ya están creados y puedes usarlos. podrías añadir otros como Vacaciones, Baja, Partido... "
                  "\nLo que necesites "
                  "\nEstos son los días que vas a poder elegir para crear tu cuadrante, y también para añadir al calendario al mantener pulsado sobre cualquier día."
                  "\nEn la siguiente pantalla tienes video explicativo",
          imagePath: 'assets/other/vacio.png'),
      const BoardingModel(
          title: '',
          subTitle: '',
          description: '',
          imagePath: 'assets/other/turnos.gif'),
      const BoardingModel(
          title: 'Cuadrantes',
          subTitle: 'Vamos a ver los',
          description:
          "Desde el menú cuadrante, creas una lista de días para un turno completo que se repetirá en el calendario."
              "\nSi tu turno, por ejemplo, se repite cada 10 días, tienes que hacer una lista con esos 10 días."
              "\n\nCuando tengas el listado de días hecho, añades la fecha de inicio, esta es la fecha en la que se añadirá el primer día del cuadrante o lista que acabas de crear"
              "\nLa fecha de fin es la fecha en la que quieres que se dejen de marcar los días en el calendario, solo indica el ultimo día del calendario que se marcara con ese cuadrante. por defecto se añade un año, si no la cambias"
              "\nTambién puedes crear una lista con solo un día, para marcar varios dias del calendario. Esto es util por ejemplo para marcar 15 dias de vacaciones en el calendario."
              "\nEn la siguiente pantalla lo veras en un video.",

          imagePath: 'assets/other/vacio.png'),
      const BoardingModel(
        title: '',
        subTitle: '',
        description: '',
        imagePath: 'assets/other/Cuadrantes.gif',
      ),
      const BoardingModel(
        subTitle: 'No te olvides nada',
        title: 'Notas',
        description:
        "Desde el menú puedes acceder a la pantalla Notas, donde puedes crear y gestionar las notas y tareas pendientes o completadas"
            "\nPodrás añadir tantas como desees al día seleccionado, las puedes borrar y editar, también desde la pantalla principal pulsando o deslizando la nota debajo del calendario, donde se muestran las notas para el día seleccionado."
            "\nEn la pantalla notas tienes un buscador por si necesitas buscar una o varias notas entre todas las guardadas y así poder consultarla o editarla de forma rápida."
            "\nTambién tiene un botón donde filtraras y se mostraran solo las marcadas como importantes si esta activado o todas si no lo esta."
            "\nA todas las notas le puedes añadir alarma para que te avise en el momento que hayas seleccionado la hora de inicio o el que elijas, ya que puedes personalizar el aviso a la hora que necesites, antes de la hora de inicio"
            "\nAhora vas a ver todo esto en un video",
        imagePath: 'assets/other/vacio.png',
      ),
      const BoardingModel(
        title: '',
        subTitle: '',
        description: '',
        imagePath: 'assets/other/Notas.gif',
      )
    ]);
  }

  void onDone() {
    AppStorage.write(
      key: APP_FIRST_TIME_OPEN,
      value: 'true',
    );
    // calendarController.onInit();
    Get.toNamed('/home');
  }


  void onPageChanged(int page) {
    pageController
        .animateToPage(page,
            duration: const Duration(milliseconds: 900), curve: Curves.ease)
        .then((_) {
      _currentPage.value = double.parse(page.toString());
    });
    if (currentPage == info.length - 1) {
      // onDone();
      return;
    }
  }

  void onButtonPressed() {
    if (currentPage == info.length - 1) {
      onDone();
      return;
    }
    tController.next();
    pageController.nextPage(
        duration: const Duration(milliseconds: 900), curve: Curves.easeOut);
    // _currentPage.value = _currentPage.value +1;

  }
}
