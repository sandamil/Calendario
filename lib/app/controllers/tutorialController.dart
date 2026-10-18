import 'package:calendario2/app/data/local/my_shared_pref.dart';
import 'package:calendario2/config/theme/my_colors.dart';
import 'package:calendario2/config/tutorial/tutorialAddTask.dart';
import 'package:calendario2/config/tutorial/tutorialCuadrantes.dart';
import 'package:calendario2/config/tutorial/tutorialInicio.dart';
import 'package:calendario2/config/tutorial/tutorialTask.dart';
import 'package:flutter/material.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

class TutorialController {
  static final TutorialController _instance = TutorialController._internal();

  factory TutorialController() => _instance;

  TutorialController._internal();

  TutorialCoachMark? tutorialCoachMark;
  List<TargetFocus> targets = [];

  Future<void> firstInstall(
    String view, {
    BuildContext? context,
    VoidCallback? onFinished,
    VoidCallback? onCuadranteTutorialFinished,
  }) async {
    // No consumir la preferencia si no hay una pantalla válida donde mostrarlo.
    if (context == null || !context.mounted) return;

    bool show = false;

    switch (view) {
      case 'home':
        show = MySharedPref.getTutoHomeFirst();
        break;
      case 'task':
        show = MySharedPref.getTutoTaskFirst();
        break;
      case 'taskAdd':
        show = MySharedPref.getTutoAddTaskFirst();
        break;
      case 'cuadrante':
        show = MySharedPref.getTutoCuadranteFirst();
        break;
      default:
        return;
    }

    if (!show || !context.mounted) return;

    showTutorial(
      context,
      view,
      onFinished: onFinished,
      onCuadranteTutorialFinished: onCuadranteTutorialFinished,
    );

    // Marcarlo como visto solo después de iniciar el tutorial con contexto válido.
    switch (view) {
      case 'home':
        await MySharedPref.setTutoHomeFirst(false);
        break;
      case 'task':
        await MySharedPref.setTutoTaskFirst(false);
        break;
      case 'taskAdd':
        await MySharedPref.setTutoAddTaskFirst(false);
        break;
      case 'cuadrante':
        await MySharedPref.setTutoCuadranteFirst(false);
        break;
    }
  }

  void showTutorial(
    BuildContext context,
    String view, {
    VoidCallback? onFinished,
    VoidCallback? onCuadranteTutorialFinished,
  }) {
    if (!context.mounted) return;

    switch (view) {
      case 'home':
        createTutorialHome(onFinished: onFinished);
        break;
      case 'task':
        createTutorialNotas(onFinished: onFinished);
        break;
      case 'taskAdd':
        createTutorialAddNotas(onFinished: onFinished);
        break;
      case 'cuadrante':
        createTutorialCuadrante(onCuadranteTutorialFinished);
        break;
      default:
        return;
    }

    tutorialCoachMark?.show(context: context);
  }

  // Tutorial de inicio
  GlobalKey? keyButton6 = GlobalKey();
  GlobalKey? keyButton7 = GlobalKey();
  GlobalKey? keyButton8 = GlobalKey();
  GlobalKey? keyButton9 = GlobalKey();

  void createTutorialHome({VoidCallback? onFinished}) {
    tutorialCoachMark = TutorialCoachMark(
      alignSkip: Alignment.bottomRight,
      targets: InicioListTarget().createTargets(
        keyButton6,
        keyButton7,
        keyButton8,
        keyButton9,
      ),
      colorShadow: PRIMARY_COLOR_DARK,
      textSkip: 'Finalizar',
      paddingFocus: 2,
      opacityShadow: 0.92,
      onFinish: () => onFinished?.call(),
      onClickTarget: (target) {},
      onClickTargetWithTapPosition: (target, tapDetails) {},
      onClickOverlay: (target) {},
      onSkip: () {
        onFinished?.call();
        return true;
      },
    );
  }

  // Tutorial de cuadrantes
  GlobalKey keyButton = GlobalKey();
  GlobalKey keyButton1 = GlobalKey();
  GlobalKey keyButton2 = GlobalKey();
  GlobalKey keyButton3 = GlobalKey();
  GlobalKey keyButton4 = GlobalKey();
  GlobalKey keyButton5 = GlobalKey();

  void createTutorialCuadrante(VoidCallback? onFinished) {
    if (onFinished == null) return;

    tutorialCoachMark = TutorialCoachMark(
      targets: ListTargetCuadrantes().createTargets(
        keyButton,
        keyButton2,
        keyButton3,
        keyButton4,
        keyButton5,
      ),
      alignSkip: Alignment.bottomLeft,
      colorShadow: PRIMARY_COLOR_DARK,
      textSkip: 'Finalizar',
      paddingFocus: 2,
      opacityShadow: 0.92,
      onFinish: onFinished,
      onClickTarget: (target) {},
      onClickTargetWithTapPosition: (target, tapDetails) {},
      onClickOverlay: (target) {},
      onSkip: () {
        onFinished();
        return true;
      },
    );
  }

  // Tutorial de notas
  GlobalKey keyButton10 = GlobalKey();
  GlobalKey keyButton11 = GlobalKey();
  GlobalKey keyButton12 = GlobalKey();
  GlobalKey keyNotasListAyuda = GlobalKey();

  void createTutorialNotas({VoidCallback? onFinished}) {
    tutorialCoachMark = TutorialCoachMark(
      alignSkip: Alignment.bottomLeft,
      targets: ListTargetTask().createTargets(
        keyButton10,
        keyButton11,
        keyButton12,
        keyNotasListAyuda,
      ),
      colorShadow: PRIMARY_COLOR_DARK,
      textSkip: 'Finalizar',
      paddingFocus: 2,
      opacityShadow: 0.92,
      onFinish: () => onFinished?.call(),
      onClickTarget: (target) {},
      onClickTargetWithTapPosition: (target, tapDetails) {},
      onClickOverlay: (target) {},
      onSkip: () {
        onFinished?.call();
        return true;
      },
    );
  }

  // Tutorial de creación de notas
  GlobalKey keyButton13 = GlobalKey();
  GlobalKey keyButton14 = GlobalKey();
  GlobalKey keyButton15 = GlobalKey();
  GlobalKey keyButton16 = GlobalKey();
  GlobalKey keyButton17 = GlobalKey();
  GlobalKey keyNotasAyuda = GlobalKey();

  void createTutorialAddNotas({VoidCallback? onFinished}) {
    tutorialCoachMark = TutorialCoachMark(
      targets: ListTargetAddTask().createTargets(
        keyButton13,
        keyButton14,
        keyButton15,
        keyButton16,
        keyButton17,
        keyNotasAyuda,
      ),
      colorShadow: PRIMARY_COLOR_DARK,
      textSkip: 'Finalizar',
      paddingFocus: 2,
      opacityShadow: 0.92,
      onFinish: () => onFinished?.call(),
      onClickTarget: (target) {},
      onClickTargetWithTapPosition: (target, tapDetails) {},
      onClickOverlay: (target) {},
      onSkip: () {
        onFinished?.call();
        return true;
      },
    );
  }
}
