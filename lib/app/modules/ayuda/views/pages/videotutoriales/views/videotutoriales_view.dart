import 'package:calendario2/app/modules/ayuda/views/pages/videotutoriales/views/widgets/video_view.dart';
import 'package:calendario2/app/modules/ayuda/views/pages/videotutoriales/views/widgets/videotutoriales_group_widget.dart';
import 'package:calendario2/app/modules/ayuda/views/pages/videotutoriales/views/widgets/videotutoriales_row_widget.dart';
import 'package:calendario2/config/theme/my_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:go_router/go_router.dart';

import '../../../../../../../config/theme/my_fonts.dart';

const String _urlHome = 'NiUMF8g00Xw';
const String _urlCrearCuadrante = 'bCSZLNRjCnc';
const String _urlEditarUnDia = '0X6ffxpI99o';
const String _urlEditarVariosDias = 'BrzgZg1p7RY';
const String _urlBackup = 'S-JYfxwbmYI';
const String _urlCrearTurno = 'LMzF1WAOSS0';
const String _urlNotas = '0vph4HSnY3s';
const String _urlFiltrosNotas = 'qNoW5vtUxoA';
const String _urlAddAlarma = '0rF_X1qMkX0';
const String _urlVistaNotaDetalle = 'Md9TEMlTFBE';

class VideotutorialesView extends StatelessWidget {
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
            context.go('/ayuda');
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
                title: "Pantalla principal",
                children: [
                  VideotutorialesRowWidget(
                      title: "Inicio",
                      subtitle:
                          "Video donde podrás ver alguna de las funciones de la pantalla principal. "
                          "Acceso a menu, Calendario anterior, uso de calendario, etc..",
                      onTap: () => context.push('/videotutoriales/${_urlHome}'),
                      id: _urlHome),
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
                      onTap: () =>
                          context.push('/videotutoriales/${_urlCrearCuadrante}'),
                      id: _urlCrearCuadrante),
                  VideotutorialesRowWidget(
                      title: "Editar un dia",
                      subtitle:
                          "Video mostrando como editar un día de cuadrante en el calendario.",
                      onTap: () =>
                          context.push('/videotutoriales/${_urlEditarUnDia}'),
                      id: _urlEditarUnDia),
                  VideotutorialesRowWidget(
                      title: "Editar varios dias",
                      subtitle:
                          "Como editar varis días juntos, sin tener que modificar de uno en uno.",
                      onTap: () => context.push('/videotutoriales/${_urlEditarVariosDias}'),
                      id: _urlEditarVariosDias),
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
                      onTap: () =>
                          context.push('/videotutoriales/${_urlBackup}'),
                      id: _urlBackup),
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
                      onTap: () =>
                          context.push('/videotutoriales/${_urlCrearTurno}'),
                      id: _urlCrearTurno),
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
                      onTap: () => context.push('/videotutoriales/${_urlNotas}'),
                      id: _urlNotas),
                  VideotutorialesRowWidget(
                      title: "Filtros de busqueda",
                      subtitle:
                          "Video mostrando como se buscan y filtran las notas dentro de la lista de todas las notas",
                      onTap: () =>
                          context.push('/videotutoriales/${_urlFiltrosNotas}'),
                      id: _urlFiltrosNotas),
                  VideotutorialesRowWidget(
                      title: "Añadir alarma",
                      subtitle:
                          "Video mostrando como añadir alarma y notificacion a las notas creadas, "
                          "solo funciona si no se cierra app.",
                      onTap: () =>
                          context.push('/videotutoriales/${_urlAddAlarma}'),
                      id: _urlAddAlarma),
                  VideotutorialesRowWidget(
                      title: "Vista detalle de Nota",
                      subtitle:
                          "Video mostrando como ver cada nota en detalle, se accede, "
                          "tanto desde pantalla principal como desde Notas.",
                      onTap: () => context.push('/videotutoriales/${_urlVistaNotaDetalle}'),
                      id: _urlVistaNotaDetalle),
                ],
              ),
            ),
          ]),
        ),
      ),
    );
  }
}
