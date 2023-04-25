import 'package:calendario2/app/data/local/app_storage.dart';
import 'package:calendario2/app/data/model/boarding_model.dart';
import 'package:calendario2/app/modules/home/controllers/calendar_controller.dart';
import 'package:calendario2/config/util/constant.dart';
import 'package:calendario2/config/util/transformer_page_view/index_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

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
              "\n\nPonte en contacto con nosotros ante cuelquier duda o sugerencia."
              "\n\nVamos a empezar, "
              "\n¡desliza la pantalla hacia la izquierda!",
          imagePath: 'assets/other/vacio.png'),
      const BoardingModel(
          title: 'Un pequeño tutorial',
          subTitle: 'Como usar la app:',
          description:
              "Para marcar los dias que trabajas o que quieres resaltar, en el calendario, tenemos que crear primero los tipos de dias que queremos añadir."
              "\n\nDesde el boton de menu accedemos a la pantalla de Turnos, y aqui creamos los tipos de dia, o turnos que vamos a usar de forma predefinida."
              "\nPuedes crear diferentes tipos de dia, si trabajas de mañanas, tardes y noches, ya estan creados y puedes usarlos. podrias añadir otros como Vacaciones, Baja, Partido... "
              "\nLo que necesites "
              "\nEstos son los dias que vas a poder elegir para crear tu cuadrante, y tambien para añadir al calendario al mantener pulsado sobre cualquier dia."
              "\nEn la siguiente pantalla tienes video explicativo",
          imagePath: 'assets/other/vacio.png'),
      const BoardingModel(
          title: '',
          subTitle: '',
          description: '',
          imagePath: 'assets/other/turnogif.gif'),
      const BoardingModel(
          title: 'Cuadrantes',
          subTitle: 'Vamos a ver los',
          description:
              "Desde el menu cuadrante, creas una lista de dias para un turno completo que se repetira en el calendario."
              "\nSi tu turno, por ejemplo, se repite cada 10 dias, tienes que hacer una lista con esos 10 dias."
              "\n\nCuando tengas el listado de dias hecho, añades la fecha de inicio, esta es la fecha en la que se añadira el primer dia del cuadrante o lista que acabas de crear"
              "\nLa fecha de fin es la fecha en la que quieres que se dejen de marcar los dias en el calendario, solo indica el ultimo dia del calendario que se marcara con ese cuadrante. por defecto se añade un año, si no la cambias"
              "\nTambien puedes crear una lista con solo un dia, para marcar varios dias del calendario. Esto es util por ejemplo para marcar 15 dias de vacaciones en el calendario."
              "\nEn la siguiente pantalla lo veras en un video.",
          imagePath: 'assets/other/vacio.png'),
      const BoardingModel(
        title: '',
        subTitle: '',
        description: '',
        imagePath: 'assets/other/cuadrantegif.gif',
      ),
      const BoardingModel(
        subTitle: 'No te olvides nada',
        title: 'Notas',
        description:
        "\nDesde el menu puedes acceder a la pantalla Notas, donde podras crear y gestionar las notas y tareas pendientes o completadas"
        "\nPodras añadir tantas como desees al dia seleccionado, las puedes borrar y editar, tambien desde la pantalla principal pulsando o deslizando la nota debajo del calendario, donde se muestran las notas para el dia seleccionado."
        "\nEn la pantalla notas tienes un buscador por si necesitas buscar una o varias notas entre todas las guardadas y asi poder consultarla o editarla de forma rapida."
        "\nTambien tiene un boton donde filtraras y se mostraran solo las marcadas como importantes si esta activado o todas si no lo esta."
        "\nA todas las notas le puedes añadir alarma para que te avise en el momento que hayas selecionado la hora de inicio o el que elijas, ya que puedes personalizar el aaviso a la hora que necesites, antes de la hora de inicio"
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

  @override
  void onClose() {
    super.onClose();
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
        duration: Duration(milliseconds: 900), curve: Curves.easeOut);
    // _currentPage.value = _currentPage.value +1;

  }
}
