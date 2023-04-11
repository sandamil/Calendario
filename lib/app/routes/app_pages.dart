import 'package:get/get.dart';

import '../modules/CrearCuadrante/bindings/crear_cuadrante_binding.dart';
import '../modules/CrearCuadrante/views/crear_cuadrante_view.dart';
import '../modules/CrearTurno/bindings/crear_turno_binding.dart';
import '../modules/CrearTurno/views/turno_view.dart';
import '../modules/ajustes/bindings/ajustes_binding.dart';
import '../modules/ajustes/views/ajustes_view.dart';
import '../modules/home/bindings/home_binding.dart';
import '../modules/home/views/home_view.dart';
import '../modules/menu/bindings/menu_binding.dart';
import '../modules/menu/views/menu_view.dart';
import '../modules/notas/bindings/notas_binding.dart';
import '../modules/notas/views/AddNotas/bindings/add_notas_binding.dart';
import '../modules/notas/views/AddNotas/views/add_notas_view.dart';
import '../modules/notas/views/EditNotas/bindings/edit_notas_binding.dart';
import '../modules/notas/views/EditNotas/views/edit_notas_view.dart';
import '../modules/notas/views/NotasView/bindings/notas_view_binding.dart';
import '../modules/notas/views/NotasView/views/notas_view.dart';
import '../modules/notas/views/notas_list_view.dart';
import 'package:calendario2/app/modules/notas/views/alarmas/bindings/alarmas_binding.dart';
import 'package:calendario2/app/modules/notas/views/alarmas/views/alarmas_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.HOME;

  static final routes = [
    GetPage(
      name: _Paths.HOME,
      page: () => HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: _Paths.AJUSTES,
      page: () => const AjustesView(),
      binding: AjustesBinding(),
    ),
    GetPage(
      name: _Paths.MENU,
      page: () => const MenuView(),
      binding: MenuBinding(),
    ),
    GetPage(
      name: _Paths.CREAR_TURNO,
      page: () => const TurnoView(),
      binding: CrearTurnoBinding(),
    ),
    GetPage(
      name: _Paths.CREAR_CUADRANTE,
      page: () => const CrearCuadranteView(),
      binding: CrearCuadranteBinding(),
    ),
    GetPage(
      name: _Paths.NOTAS,
      page: () => const NotasListView(),
      binding: NotasListBinding(),
    ),
    GetPage(
      name: _Paths.NOTAS_VIEW,
      page: () => const NotasView(),
      binding: NotasViewBinding(),
    ),
    GetPage(
      name: _Paths.ADD_NOTAS,
      page: () => const AddNotasView(),
      binding: AddNotasBinding(),
    ),
    GetPage(
      name: _Paths.EDIT_NOTAS,
      page: () => const EditNotasView(),
      binding: EditNotasBinding(),
    ),
    GetPage(
      name: _Paths.ALARMAS,
      page: () => const AlarmasView(),
      binding: AlarmasBinding(),
    ),
  ];
}
