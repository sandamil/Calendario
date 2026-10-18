import '../modules/notas/views/EditNotas/bindings/edit_notas_binding.dart';
import '../modules/notas/views/AddNotas/bindings/add_notas_binding.dart';
import 'dart:io';

import 'package:calendario2/app/modules/ajustes/views/pages/dev_page.dart';
import 'package:calendario2/app/modules/ajustes/views/pages/log_console.dart';
import 'package:calendario2/app/modules/ayuda/views/pages/videotutoriales/views/videotutoriales_view.dart';
import 'package:get/get.dart';

import '../modules/CrearTurno/views/turno_view.dart';
import '../modules/ajustes/bindings/ajustes_binding.dart';
import '../modules/ajustes/views/ajustes_view.dart';
import '../modules/ajustes/views/pages/about_page.dart';
import '../modules/ajustes/views/pages/privacy_policy_page.dart';
import '../modules/ayuda/views/ayuda_view.dart';
import '../modules/boarding/views/boarding_view.dart';
import '../modules/crearCuadrante/views/cuadrante_view.dart';
import '../modules/home/views/home_view.dart';
import '../modules/inicio/views/inicio_view.dart';
import '../modules/menu/views/menu_view.dart';
import '../modules/notas/views/AddNotas/views/add_notas_view.dart';
import '../modules/notas/views/EditNotas/views/edit_notas_view.dart';
import '../modules/notas/views/NotasView/bindings/notas_view_binding.dart';
import '../modules/notas/views/NotasView/views/notas_view.dart';
import '../modules/notas/views/alarmas/bindings/alarmas_binding.dart';
import '../modules/notas/views/alarmas/views/alarmas_view.dart';
import '../modules/notas/views/notas_list_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.HOME;

  static final routes = [
    GetPage(
      name: _Paths.INICIO,
      page: () => const InicioView(),
    ),
    GetPage(
      name: _Paths.BOARDING,
      page: () => BoardingView(),
    ),
    GetPage(
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 100),
      name: _Paths.HOME,
      page: () => HomeView(),
    ),
    GetPage(
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 100),
      name: _Paths.AJUSTES,
      page: () => AjustesView(),
      binding: AjustesBinding(),
    ),
    GetPage(
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 100),
      name: _Paths.MENU,
      page: () => const MenuView(),
    ),
    GetPage(
      transition: Transition.fadeIn,
      transitionDuration: const Duration(microseconds: 100),
      name: _Paths.CREAR_TURNO,
      page: () => const TurnoView(),
    ),
    GetPage(
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 100),
      name: _Paths.CREAR_CUADRANTE,
      page: () => const CrearCuadranteView(),
    ),
    GetPage(
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 100),
      name: _Paths.NOTAS,
      page: () => NotasListView(),
    ),
    GetPage(
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 100),
      name: _Paths.NOTAS_VIEW,
      page: () => const NotasView(),
      binding: NotasViewBinding(),
    ),
    GetPage(
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 100),
      name: _Paths.ADD_NOTAS,
      page: () => AddNotasView(),
      binding: AddNotasBinding(),
    ),
    GetPage(
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 100),
      name: _Paths.EDIT_NOTAS,
      page: () => EditNotasView(),
      binding: EditNotasBinding(),
    ),
    GetPage(
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 100),
      name: _Paths.ALARMAS,
      page: () => const AlarmasView(),
      binding: AlarmasBinding(),
    ),
    GetPage(
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 100),
      name: _Paths.AYUDA,
      page: () => const AyudaView(),
    ),
    GetPage(
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 100),
      name: _Paths.VIDEOTUTORIALES,
      page: () => const VideotutorialesView(),
    ),
  ];
}

class RouteUtils {
  static Transition transition =
      (Platform.isAndroid) ? Transition.downToUp : Transition.cupertino;

  static Future? toAboutPage() {
    return Get.to(
      () => AboutPage(),
      transition: transition,
    );
  }

  static Future? toPrivacyPolicyPage() {
    return Get.to(
      () => PrivacyPolicyPage(),
      transition: transition,
    );
  }

  static Future? toDevPage() {
    return Get.to(
      () => const DevPage(),
      transition: transition,
    );
  }

  static Future? toLogConsolePage() {
    return Get.to(
      () => LogConsole(dark: true),
      transition: transition,
    );
  }
}
