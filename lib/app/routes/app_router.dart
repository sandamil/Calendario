import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../modules/inicio/views/inicio_view.dart';
import '../modules/boarding/views/boarding_view.dart';
import '../modules/home/views/home_view.dart';
import '../modules/ajustes/views/ajustes_view.dart';
import '../modules/menu/views/menu_view.dart';
import '../modules/CrearTurno/views/turno_view.dart';
import '../modules/crearCuadrante/views/cuadrante_view.dart';
import '../modules/crearCuadrante/views/add_cuadrante_view.dart';
import '../modules/notas/views/notas_list_view.dart';
import '../modules/notas/views/NotasView/views/notas_view.dart';
import '../modules/notas/views/AddNotas/views/add_notas_view.dart';
import '../modules/notas/views/EditNotas/views/edit_notas_view.dart';
import '../modules/notas/views/alarmas/views/alarmas_view.dart';
import '../modules/ayuda/views/ayuda_view.dart';
import '../modules/ayuda/views/pages/videotutoriales/views/videotutoriales_view.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/inicio',
  routes: [
    GoRoute(
      path: '/inicio',
      builder: (context, state) => const InicioView(),
    ),
    GoRoute(
      path: '/boarding',
      builder: (context, state) => BoardingView(),
    ),
    GoRoute(
      path: '/home',
      pageBuilder: (context, state) => CustomTransitionPage<void>(
        key: state.pageKey,
        child: HomeView(),
        transitionDuration: const Duration(milliseconds: 100),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    ),
    GoRoute(
      path: '/ajustes',
      pageBuilder: (context, state) => CustomTransitionPage<void>(
        key: state.pageKey,
        child: AjustesView(),
        transitionDuration: const Duration(milliseconds: 100),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    ),
    GoRoute(
      path: '/menu',
      builder: (context, state) => const MenuView(),
    ),
    GoRoute(
      path: '/crear-turno',
      builder: (context, state) => const TurnoView(),
    ),
    GoRoute(
      path: '/crear-cuadrante',
      builder: (context, state) => const CrearCuadranteView(),
    ),
    GoRoute(
      path: '/add-cuadrante',
      builder: (context, state) => const AddCuadranteView(),
    ),
    GoRoute(
      path: '/notas',
      builder: (context, state) => NotasListView(),
    ),
    GoRoute(
      path: '/notas-view',
      builder: (context, state) => NotasView(routeArguments: state.extra),
    ),
    GoRoute(
      path: '/add-notas',
      builder: (context, state) => AddNotasView(routeArguments: state.extra),
    ),
    GoRoute(
      path: '/edit-notas',
      builder: (context, state) => EditNotasView(routeArguments: state.extra),
    ),
    GoRoute(
      path: '/alarmas',
      builder: (context, state) => AlarmasView(routeArguments: state.extra),
    ),
    GoRoute(
      path: '/ayuda',
      builder: (context, state) => const AyudaView(),
    ),
    GoRoute(
      path: '/videotutoriales',
      builder: (context, state) => const VideotutorialesView(),
    ),
  ],
);
