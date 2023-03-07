import 'package:get/get.dart';

import '../modules/CrearCuadrante/bindings/crear_cuadrante_binding.dart';
import '../modules/CrearCuadrante/views/crear_cuadrante_view.dart';
import '../modules/CrearTurno/bindings/crear_turno_binding.dart';
import '../modules/CrearTurno/views/crear_turno_view.dart';
import '../modules/ajustes/bindings/ajustes_binding.dart';
import '../modules/ajustes/views/ajustes_view.dart';
import '../modules/home/bindings/home_binding.dart';
import '../modules/home/views/home_view.dart';
import '../modules/menu/bindings/menu_binding.dart';
import '../modules/menu/bindings/menu_binding.dart';
import '../modules/menu/bindings/menu_binding.dart';
import '../modules/menu/views/menu_view.dart';
import '../modules/menu/views/menu_view.dart';
import '../modules/menu/views/menu_view.dart';

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
      children: [
        GetPage(
          name: _Paths.MENU,
          page: () => const MenuView(),
          binding: MenuBinding(),
        ),
        GetPage(
          name: _Paths.MENU,
          page: () => const MenuView(),
          binding: MenuBinding(),
        ),
      ],
    ),
    GetPage(
      name: _Paths.CREAR_TURNO,
      page: () => const CrearTurnoView(),
      binding: CrearTurnoBinding(),
    ),
    GetPage(
      name: _Paths.CREAR_CUADRANTE,
      page: () => const CrearCuadranteView(),
      binding: CrearCuadranteBinding(),
    ),
  ];
}
