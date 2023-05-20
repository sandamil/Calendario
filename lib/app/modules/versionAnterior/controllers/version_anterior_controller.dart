import 'package:calendario2/app/data/local/previusTaskDatabase.dart';
import 'package:calendario2/app/data/model/previousDatabase/previousTaskModel.dart';
import 'package:calendario2/app/modules/versionAnterior/views/pages/notas_version_anterior_screen.dart';
import 'package:calendario2/app/modules/versionAnterior/views/pages/turnos_calendario_VA_screen.dart';
import 'package:calendario2/app/modules/versionAnterior/views/pages/turnos_personalizados_VA_screen.dart';
import 'package:calendario2/app/modules/versionAnterior/views/widgets/ShiftsBkpCard.dart';
import 'package:calendario2/app/modules/versionAnterior/views/widgets/notasBkpCard.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../data/model/previousDatabase/customShiftTemplate.dart';
import '../../../data/model/previousDatabase/previousShift.dart';
import '../views/widgets/turnosCalendarioBkpCard.dart';

class VersionAnteriorController extends GetxController {
  late PreviousShift shift;

  RxString shiftName = ''.obs;

  final Uri _url = Uri.parse('https://drive.google.com/file/d/1qno2uZNL88bItxBR4CigHnd3S8_SZIB8/view');



  @override
  void onInit() {
    setNotesFromDB();
    setTurnosPersonalizadosFromDB();
    setTurnosCalendarioFromDB();
    super.onInit();
  }



  RxList<PreviousTask> notesBkpList = <PreviousTask>[].obs;
  RxList<PreviousShift> turnosPersonalizadosBkpList = <PreviousShift>[].obs;
  RxList<CustomShitTemplate> turnosCalendarioBkpList = <CustomShitTemplate>[].obs;

  void goToNotasVersionAnteriorScreen() {
    Get.to(
          () => const NotasVersionAnteriorScreen(),
      transition: Transition.fadeIn,
      duration: const Duration(milliseconds: 100),
    );
  }
void goToTurnosCalendarioScreen() {
    Get.to(
          () => const TurnosCalendarioScreen(),
      transition: Transition.fadeIn,
      duration: const Duration(milliseconds: 100),
    );
  }
void goToTurnosPersonalizadosScreen() {
    Get.to(
          () => const TurnosPersonalizadosScreen(),
      transition: Transition.fadeIn,
      duration: const Duration(milliseconds: 100),
    );
  }

  setNotesFromDB() async {
    notesBkpList.value = await PreviusDbProvider.instance.getPreviousTaskFromDB();
    return notesBkpList.value;
  }
 setTurnosPersonalizadosFromDB() async {
   turnosPersonalizadosBkpList.value = await PreviusDbProvider.instance.getTurnosPersonalizadosFromDB();
    return turnosPersonalizadosBkpList.value;
  }
 setTurnosCalendarioFromDB() async {
   turnosCalendarioBkpList.value = await PreviusDbProvider.instance.getTurnosCalendarioFromDB();
    return turnosCalendarioBkpList.value;
  }



  List<Widget> buildNoteBkpComponentsList() {
    List<Widget> noteBkcComponentsList = [];
    notesBkpList.value.sort((a, b) {
      return b.year!.compareTo(a.year as num);
    });
    notesBkpList.value.forEach((note) {
      noteBkcComponentsList.add(NotasBkpCard(
        noteData: note,
        // onTapAction: openNoteToRead,
      ));
    });

    return noteBkcComponentsList;
  }

  List<Widget> buildTurnosPersonalizadosList() {
    List<Widget> turnosPersBkcComponentsList = [];
    turnosPersonalizadosBkpList.value.forEach((note) {
      turnosPersBkcComponentsList.add(ShiftsBkpCard(
        noteData: note,
        // onTapAction: openNoteToRead,
      ));
    });

    return turnosPersBkcComponentsList;
  }




  List<Widget> buildTurnosCalendarioList() {
    List<Widget> turnosCalBkcComponentsList = [];
    turnosCalendarioBkpList.value.sort((a, b) {
      return b.year!.compareTo(a.year as num);
    });
    turnosCalendarioBkpList.value.forEach((note) {
      turnosCalBkcComponentsList.add(TurnosCalendarioBkpCard(
        noteData: note,
        // onTapAction: openNoteToRead,
      ));
    });

    return turnosCalBkcComponentsList;
  }




   getShiftFromDB(id) async {
    shift = await PreviusDbProvider.instance.getShift(id);

    shiftName.value = shift.title!;
    update();
    return shift;
  }

  Future<void>  descargaVersionAnterior() async{
      if (!await launchUrl(_url)) {
        throw Exception('Could not launch $_url');
      }

  }



}
