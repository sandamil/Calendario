import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../data/model/turnoType.dart';
import '../modules/boarding/views/boarding_view.dart';
import '../modules/home/views/home_view.dart';
import '../modules/ajustes/views/ajustes_view.dart';
import '../modules/ajustes/views/pages/backup_screen.dart';
import '../modules/ajustes/views/pages/language_screen.dart';
import '../modules/menu/views/menu_view.dart';
import '../modules/crearTurno/views/turno_view.dart';
import '../modules/crearTurno/views/add_turno_view.dart';
import '../modules/crearTurno/views/edit_turno_view.dart';
import '../modules/ajustes/views/pages/about_page.dart';
import '../modules/ajustes/views/pages/privacy_policy_page.dart';
import '../modules/ajustes/views/pages/dev_page.dart';
import '../modules/ajustes/views/pages/log_console.dart';
import '../modules/crearCuadrante/views/cuadrante_view.dart';
import '../modules/crearCuadrante/views/add_cuadrante_view.dart';
import '../modules/notas/views/notas_list_view.dart';
import '../modules/notas/views/NotasView/views/notas_view.dart';
import '../modules/notas/views/AddNotas/views/add_notas_view.dart';
import '../modules/notas/views/EditNotas/views/edit_notas_view.dart';
import '../modules/notas/views/alarmas/views/alarmas_view.dart';
import '../modules/ayuda/views/ayuda_view.dart';
import '../modules/ayuda/views/pages/videotutoriales/views/videotutoriales_view.dart';
import '../modules/ayuda/views/pages/videotutoriales/views/widgets/video_view.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/home',
  routes: [
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
      path: '/backup',
      builder: (context, state) => const BackupScreen(),
    ),
    GoRoute(
      path: '/idioma',
      builder: (context, state) => const LanguageScreen(),
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
      path: '/add-turno',
      builder: (context, state) => const AddTurnoView(),
    ),
    GoRoute(
      path: '/edit-turno',
      builder: (context, state) => EditTurnoView(state.extra as TurnoType),
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
      path: '/about',
      builder: (context, state) => const AboutPage(),
    ),
    GoRoute(
      path: '/privacy-policy',
      builder: (context, state) => PrivacyPolicyPage(),
    ),
    GoRoute(
      path: '/dev',
      builder: (context, state) => const DevPage(),
    ),
    GoRoute(
      path: '/log-console',
      builder: (context, state) => LogConsole(dark: true),
    ),
    GoRoute(
      path: '/ayuda',
      builder: (context, state) => const AyudaView(),
    ),
    GoRoute(
      path: '/videotutoriales',
      builder: (context, state) => const VideotutorialesView(),
    ),
    GoRoute(
      path: '/videotutoriales/:id',
      builder: (context, state) => FullscreenVideoViewer(
        id: state.pathParameters['id']!,
      ),
    ),
  ],
);
