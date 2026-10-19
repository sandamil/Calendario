import 'package:calendario2/app/components/custom_dialog.dart';
import 'package:calendario2/app/data/model/turnoType.dart';
import 'package:calendario2/config/theme/my_colors.dart';
import 'package:calendario2/config/theme/my_fonts.dart';
import 'package:calendario2/config/util/app_utils.dart';
import 'package:calendario2/config/util/dateUtils.dart';
import 'package:calendario2/config/util/hexColor.dart';
import 'package:calendario2/config/util/validation_utils.dart';
import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../home/providers/calendar_providers.dart';
import 'widgets/input_field.dart';

class TurnoFormView extends ConsumerStatefulWidget {
  const TurnoFormView({super.key, this.turno});

  final TurnoType? turno;

  @override
  ConsumerState<TurnoFormView> createState() => _TurnoFormViewState();
}

class _TurnoFormViewState extends ConsumerState<TurnoFormView> {
  late final TextEditingController _abreviaturaController;
  late final TextEditingController _tituloController;

  late String _inicio;
  late String _fin;
  late Color _color;

  bool _guardando = false;

  bool get _esEdicion => widget.turno != null;

  @override
  void initState() {
    super.initState();

    final turno = widget.turno;
    _abreviaturaController = TextEditingController(text: turno?.title ?? '');
    _tituloController = TextEditingController(text: turno?.description ?? '');

    _inicio = turno?.startHour ?? DateTime.now().formatDateTime24H;
    _fin = turno?.endHour ??
        DateTime.now().add(const Duration(hours: 1)).formatDateTime24H;

    _color =
        turno?.color != null ? HexColor(turno!.color!) : Colors.orangeAccent;
  }

  @override
  void dispose() {
    _abreviaturaController.dispose();
    _tituloController.dispose();
    super.dispose();
  }

  Future<void> _seleccionarHora({required bool esInicio}) async {
    final valorActual = esInicio ? _inicio : _fin;
    final partes = valorActual.split(':');
    var horaInicial = TimeOfDay.now();

    if (partes.length == 2) {
      final hora = int.tryParse(partes[0]);
      final minuto = int.tryParse(partes[1]);

      if (hora != null &&
          minuto != null &&
          hora >= 0 &&
          hora < 24 &&
          minuto >= 0 &&
          minuto < 60) {
        horaInicial = TimeOfDay(hour: hora, minute: minuto);
      }
    }

    final hora = await showTimePicker(
      context: context,
      initialTime: horaInicial,
      helpText:
          esInicio ? 'Selecciona hora de inicio' : 'Selecciona hora de fin',
      cancelText: 'Cancelar',
      confirmText: 'Ok',
    );

    if (hora == null || !mounted) return;

    setState(() {
      if (esInicio) {
        _inicio =
            '${hora.hour.toString().padLeft(2, '0')}:${hora.minute.toString().padLeft(2, '0')}';
      } else {
        _fin =
            '${hora.hour.toString().padLeft(2, '0')}:${hora.minute.toString().padLeft(2, '0')}';
      }
    });
  }

  Future<void> _seleccionarColor() async {
    Color colorTemporal = _color;

    final colorElegido = await showDialog<Color>(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final theme = Theme.of(context);

            return AlertDialog(
              backgroundColor: theme.cardColor,
              title: const Text('Selecciona color'),
              content: SizedBox(
                width: 320,
                height: 440,
                child: ColorPicker(
                  color: colorTemporal,
                  onColorChanged: (color) {
                    setDialogState(() {
                      colorTemporal = color;
                    });
                  },
                  width: 40,
                  height: 40,
                  borderRadius: 5.r,
                  spacing: 5,
                  runSpacing: 5,
                  wheelDiameter: 155,
                  heading: const Text('Selecciona color'),
                  subheading: const Text('Selecciona tono color'),
                  showMaterialName: false,
                  showColorName: false,
                  showColorCode: false,
                  copyPasteBehavior: const ColorPickerCopyPasteBehavior(
                    longPressMenu: false,
                  ),
                  pickersEnabled: const <ColorPickerType, bool>{
                    ColorPickerType.both: false,
                    ColorPickerType.primary: true,
                    ColorPickerType.accent: true,
                    ColorPickerType.bw: false,
                    ColorPickerType.custom: true,
                    ColorPickerType.wheel: false,
                  },
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Cancelar'),
                ),
                TextButton(
                  onPressed: () =>
                      Navigator.of(dialogContext).pop(colorTemporal),
                  child: const Text('Aceptar'),
                ),
              ],
            );
          },
        );
      },
    );

    if (colorElegido == null || !mounted) return;

    setState(() {
      _color = colorElegido;
    });
  }

  Future<void> _guardar() async {
    if (!ValidationUtils.isValidString(_tituloController.text)) {
      MyCustomDialog.alertaError(
        'Necesitas añadir un Título válido.',
        duracion: 3,
        context: context,
      );
      return;
    }

    if (_guardando) return;

    setState(() {
      _guardando = true;
    });

    try {
      final turno = TurnoType(
        id: widget.turno?.id,
        title: _abreviaturaController.text,
        description: _tituloController.text.trim(),
        startHour: _inicio,
        endHour: _fin,
        color: _color.value.toRadixString(16),
      );

      if (_esEdicion) {
        await ref.read(turnoTypesProvider.notifier).updateTurno(turno);
      } else {
        await ref.read(turnoTypesProvider.notifier).addTurno(turno);
      }

      if (!mounted) return;

      final resultado = ref.read(turnoTypesProvider);

      if (resultado.hasError) {
        MyCustomDialog.alertaError(
          'No se pudo guardar el tipo de turno. Comprueba los datos e inténtalo de nuevo.',
          duracion: 4,
          context: context,
        );
        return;
      }

      if (_esEdicion) {
        await ref.read(cuadranteMapProvider.notifier).reload();
        if (!mounted) return;
      }

      final turnosGuardados = resultado.asData?.value ?? const <TurnoType>[];
      final guardadoConfirmado = _esEdicion
          ? turnosGuardados.any((item) => item.id == turno.id)
          : turnosGuardados.any(
              (item) =>
                  item.title == turno.title &&
                  item.description == turno.description &&
                  item.startHour == turno.startHour &&
                  item.endHour == turno.endHour &&
                  item.color == turno.color,
            );

      if (!guardadoConfirmado) {
        MyCustomDialog.alertaError(
          'No se ha podido confirmar el guardado del tipo de turno. Comprueba si ya existe y vuelve a intentarlo.',
          duracion: 4,
          context: context,
        );
        return;
      }

      context.pop();
    } catch (error) {
      if (!mounted) return;

      MyCustomDialog.alertaError(
        'No se pudo guardar el tipo de turno: $error',
        duracion: 4,
        context: context,
      );
    } finally {
      if (mounted) {
        setState(() {
          _guardando = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorTexto =
        _color.computeLuminance() > 0.5 ? Colors.black : Colors.white;

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: AppUtils.dismissKeyboard,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios,
              size: 26.sp,
              color: colorTexto,
            ),
            onPressed: () => context.pop(),
          ),
          elevation: 0,
          centerTitle: false,
          backgroundColor: _color,
          title: Text(
            _esEdicion ? 'Editar Turno' : 'Crear Turno',
            style: CustomTextStyle.appBarTitle(context: context)
                .copyWith(color: colorTexto),
          ),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.only(
              top: 50.h,
              left: 15.w,
              right: 15.w,
              bottom: 30.h,
            ),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Spacer(),
                    SizedBox(
                      width: 60.w,
                      child: TextField(
                        controller: _abreviaturaController,
                        maxLength: 3,
                        onChanged: (_) => setState(() {}),
                        decoration: const InputDecoration(
                          hintText: 'Abreviatura',
                          labelText: 'Abreviatura',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(15),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const Spacer(),
                    const Spacer(),
                    Column(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: MyColors.borderCellColor,
                              width: 2,
                            ),
                            color: MyColors.backgroundLowAccent,
                            borderRadius: BorderRadius.circular(5.r),
                          ),
                          width: 65,
                          height: 90,
                          child: Column(
                            children: [
                              const Padding(
                                padding: EdgeInsets.all(4),
                                child: Text(
                                  '15',
                                  style: TextStyle(fontSize: 18),
                                ),
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: _color,
                                    width: 2,
                                  ),
                                  color: _color.withAlpha(100),
                                  borderRadius: BorderRadius.circular(5.r),
                                ),
                                padding: EdgeInsets.symmetric(
                                  horizontal: 5.w,
                                ),
                                child: Text(
                                  _abreviaturaController.text
                                          .toUpperCase()
                                          .isEmpty
                                      ? '        '
                                      : _abreviaturaController.text
                                          .toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: _color,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 5),
                          child: Text(
                            'VISTA PREVIA\nEN CALENDARIO',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                  ],
                ),
                const SizedBox(height: 30),
                TextField(
                  controller: _tituloController,
                  onChanged: (_) => setState(() {}),
                  decoration: const InputDecoration(
                    hintText: 'Nombre del tipo de turno o día creado',
                    labelText: 'Título',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(15)),
                    ),
                  ),
                  maxLines: 1,
                  maxLength: 12,
                ),
                const SizedBox(height: 30),
                Row(
                  children: [
                    Expanded(
                      child: InputField(
                        label: 'Inicio',
                        hintText: _inicio,
                        widget: IconButton(
                          onPressed: () => _seleccionarHora(esInicio: true),
                          icon: const Icon(Icons.access_time_rounded),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: InputField(
                        label: 'Fin',
                        hintText: _fin,
                        widget: IconButton(
                          onPressed: () => _seleccionarHora(esInicio: false),
                          icon: const Icon(Icons.access_time_rounded),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 50),
                InkWell(
                  onTap: _seleccionarColor,
                  child: Material(
                    type: MaterialType.circle,
                    color: _color,
                    child: const SizedBox(
                      height: 100,
                      width: 100,
                    ),
                  ),
                ),
                const SizedBox(height: 50),
                Hero(
                  tag: 'botonAddTurno',
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 4.h,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5.r),
                      ),
                    ),
                    onPressed: _guardando ? null : _guardar,
                    child: Text(
                      _guardando
                          ? 'Guardando...'
                          : (_esEdicion ? 'Editar' : 'Añadir'),
                      style: CustomTextStyle.button,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
