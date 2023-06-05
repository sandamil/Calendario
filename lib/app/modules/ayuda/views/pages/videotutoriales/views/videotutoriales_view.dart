import 'package:calendario2/app/modules/ayuda/views/pages/videotutoriales/views/widgets/video_view.dart';
import 'package:calendario2/app/modules/ayuda/views/pages/videotutoriales/views/widgets/videotutoriales_group_widget.dart';
import 'package:calendario2/app/modules/ayuda/views/pages/videotutoriales/views/widgets/videotutoriales_row_widget.dart';
import 'package:calendario2/config/theme/my_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:get/get.dart';

import '../../../../../../../config/theme/my_fonts.dart';
import '../controllers/videotutoriales_controller.dart';

class VideotutorialesView extends GetView<VideotutorialesController> {
  const VideotutorialesView({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        centerTitle: false,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: PRIMARY_COLOR,
            size: 26.sp,
          ),
          onPressed: () {
            Get.offAndToNamed('/ayuda');
          },
        ),
        title: Text(
          'Videotutoriales',
          style: CustomTextStyle.appBarTitle(context: context),
        ),
      ),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 10.w),
        child: SingleChildScrollView(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Card(
              color: MyColors.menuCardBackgroundDark,

              child: VideotutorialesViewGroup(
                title: "Version Anterior",
                children: [
                  VideotutorialesRowWidget(
                      title: "Acceso a datos guardados",
                      subtitle:
                          "Video mostrando como acceder a datos guardados, de version anterior de aplicación.",
                      onTap: () => Get.to(FullscreenVideoViewer(
                          id: controller.urlVersionAnterior)),
                      id: controller.urlVersionAnterior),
                ],
              ),
            ),
            Card(
              color: MyColors.menuCardBackgroundDark,

              child: VideotutorialesViewGroup(
                title: "Pantalla principal",
                children: [
                  VideotutorialesRowWidget(
                      title: "Inicio",
                      subtitle:
                          "Video donde podrás ver alguna de las funciones de la pantalla principal. "
                          "Acceso a menu, Calendario anterior, uso de calendario, etc..",
                      onTap: () =>
                          Get.to(FullscreenVideoViewer(id: controller.urlHome)),
                      id: controller.urlHome),
                ],
              ),
            ),
            Card(
              color: MyColors.menuCardBackgroundDark,

              child: VideotutorialesViewGroup(
                title: "Cuadrantes",
                children: [
                  VideotutorialesRowWidget(
                      title: "Crear Cuadrantes",
                      subtitle:
                          "Video mostrando como crear un cuadrante para marcar los días de trabajo en el calendario.",
                      onTap: () => Get.to(FullscreenVideoViewer(
                          id: controller.urlCrearCuadrante)),
                      id: controller.urlCrearCuadrante),
                  VideotutorialesRowWidget(
                      title: "Editar un dia",
                      subtitle:
                      "Video mostrando como editar un día de cuadrante en el calendario.",
                      onTap: () => Get.to(FullscreenVideoViewer(
                          id: controller.urlEditarUnDia)),
                      id: controller.urlEditarUnDia),
                  VideotutorialesRowWidget(
                      title: "Editar varios dias",
                      subtitle:
                      "Como editar varis días juntos, sin tener que modificar de uno en uno.",
                      onTap: () => Get.to(FullscreenVideoViewer(
                          id: controller.urlEditarVariosDias)),
                      id: controller.urlEditarVariosDias),
                ],
              ),
            ),
            Card(
              color: MyColors.menuCardBackgroundDark,

              child: VideotutorialesViewGroup(
                title: "Copia de Seguridad",
                children: [
                  VideotutorialesRowWidget(
                      title: "Backup",
                      subtitle:
                          "Video mostrando como hacer copia de seguridad y restaurar datos de app.",
                      onTap: () => Get.to(FullscreenVideoViewer(
                          id: controller.urlbackup)),
                      id: controller.urlbackup),
                ],
              ),
            ),
            Card(
              color: MyColors.menuCardBackgroundDark,

              child: VideotutorialesViewGroup(
                title: "Turnos",
                children: [
                  VideotutorialesRowWidget(
                      title: "Crear Turnos",
                      subtitle:
                          "Video mostrando como crear un turno para marcar los días en el calendario,"
                          " o crear cuadrantes con ese turno o tipo de dia.",
                      onTap: () => Get.to(
                          FullscreenVideoViewer(id: controller.urlCrearTurno)),
                      id: controller.urlCrearTurno),
                ],
              ),
            ),
            Card(
              color: MyColors.menuCardBackgroundDark,

              child: VideotutorialesViewGroup(
                title: "Notas",
                children: [
                  VideotutorialesRowWidget(
                      title: "Crear Nota",
                      subtitle:
                          "Video general de la pantalla Notas, donde verás las principales características.",
                      onTap: () => Get.to(
                          FullscreenVideoViewer(id: controller.urlNotas)),
                      id: controller.urlNotas),
                  VideotutorialesRowWidget(
                      title: "Filtros de busqueda",
                      subtitle:
                          "Video mostrando como se buscan y filtran las notas dentro de la lista de todas las notas",
                      onTap: () => Get.to(FullscreenVideoViewer(
                          id: controller.urlFiltrosNotas)),
                      id: controller.urlFiltrosNotas),
                  VideotutorialesRowWidget(
                      title: "Añadir alarma",
                      subtitle:
                          "Video mostrando como añadir alarma y notificacion a las notas creadas, "
                          "solo funciona si no se cierra app.",
                      onTap: () => Get.to(
                          FullscreenVideoViewer(id: controller.urlAddAlarma)),
                      id: controller.urlAddAlarma),
                  VideotutorialesRowWidget(
                      title: "Vista detalle de Nota",
                      subtitle:
                          "Video mostrando como ver cada nota en detalle, se accede, "
                          "tanto desde pantalla principal como desde Notas.",
                      onTap: () => Get.to(FullscreenVideoViewer(
                          id: controller.urlVistaNotaDetalle)),
                      id: controller.urlVistaNotaDetalle),
                ],
              ),
            ),
          ]),
        ),
      ),
    );
  }
}
