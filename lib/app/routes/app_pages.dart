import 'package:get/get.dart';

import '../modules/crearCuadrante/bindings/crear_cuadrante_binding.dart';
import '../modules/crearCuadrante/views/crear_cuadrante_view.dart';
import '../modules/CrearTurno/bindings/crear_turno_binding.dart';
import '../modules/CrearTurno/views/turno_view.dart';
import '../modules/ajustes/bindings/ajustes_binding.dart';
import '../modules/ajustes/views/ajustes_view.dart';
import '../modules/ayuda/bindings/ayuda_binding.dart';
import '../modules/ayuda/views/ayuda_view.dart';
import '../modules/boarding/bindings/boarding_binding.dart';
import '../modules/boarding/views/boarding_view.dart';
import '../modules/home/bindings/home_binding.dart';
import '../modules/home/views/home_view.dart';
import '../modules/inicio/bindings/inicio_binding.dart';
import '../modules/inicio/views/inicio_view.dart';
import '../modules/menu/bindings/menu_binding.dart';
import '../modules/menu/views/menu_view.dart';
import '../modules/notas/bindings/notas_binding.dart';
import '../modules/notas/views/AddNotas/bindings/add_notas_binding.dart';
import '../modules/notas/views/AddNotas/views/add_notas_view.dart';
import '../modules/notas/views/EditNotas/bindings/edit_notas_binding.dart';
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
      binding: InicioBinding(),
    ),

    GetPage(
      name: _Paths.BOARDING,
      page: () => const BoardingView(),
      binding: BoardingBinding(),
    ),
    GetPage(
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 100),
      name: _Paths.HOME,
      page: () => HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 100),
      name: _Paths.AJUSTES,
      page: () => const AjustesView(),
      binding: AjustesBinding(),
    ),
    GetPage(
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 100),
      name: _Paths.MENU,
      page: () => const MenuView(),
      binding: MenuBinding(),
    ),
    GetPage(
      transition: Transition.fadeIn,
      transitionDuration: const Duration(microseconds: 100),
      name: _Paths.CREAR_TURNO,
      page: () => const TurnoView(),
      binding: CrearTurnoBinding(),
    ),
    GetPage(
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 100),
      name: _Paths.CREAR_CUADRANTE,
      page: () => const CrearCuadranteView(),
      binding: CrearCuadranteBinding(),
    ),
    GetPage(
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 100),
      name: _Paths.NOTAS,
      page: () => const NotasListView(),
      binding: NotasListBinding(),
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
      page: () => const AddNotasView(),
      binding: AddNotasBinding(),
    ),
    GetPage(
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 100),
      name: _Paths.EDIT_NOTAS,
      page: () => const EditNotasView(),
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
      binding: AyudaBinding(),
    ),

  ];
}
