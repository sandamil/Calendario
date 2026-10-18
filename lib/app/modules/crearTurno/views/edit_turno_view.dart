import 'package:flutter/material.dart';

import '../../../data/model/turnoType.dart';
import 'turno_form_view.dart';

class EditTurnoView extends StatelessWidget {
  const EditTurnoView(this.turno, {super.key});

  final TurnoType turno;

  @override
  Widget build(BuildContext context) => TurnoFormView(turno: turno);
}
