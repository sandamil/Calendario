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
    final theme = Theme.of(context);
    final textColor = theme.colorScheme.onSurface;
    final mutedColor = textColor.withValues(alpha: .58);
    final previewTextColor =
        _color.computeLuminance() > .52 ? Colors.black87 : Colors.white;
    final previewBorderColor = _color.computeLuminance() > .86
        ? theme.colorScheme.outline
        : _color;

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: AppUtils.dismissKeyboard,
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back_rounded, size: 24.sp, color: textColor),
            onPressed: () => context.pop(),
          ),
          elevation: 0,
          centerTitle: false,
          backgroundColor: theme.scaffoldBackgroundColor,
          title: Text(
            _esEdicion ? 'Editar turno' : 'Crear turno',
            style: CustomTextStyle.appBarTitle(context: context)
                .copyWith(color: textColor),
          ),
        ),
        body: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: Padding(
            padding: EdgeInsets.fromLTRB(18.w, 10.h, 18.w, 28.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(14.w),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: .38),
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(
                      color: theme.colorScheme.outlineVariant.withValues(alpha: .35),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 46.w,
                        height: 46.w,
                        decoration: BoxDecoration(
                          color: PRIMARY_COLOR.withValues(alpha: .14),
                          borderRadius: BorderRadius.circular(15.r),
                        ),
                        child: Icon(
                          _esEdicion
                              ? Icons.edit_calendar_rounded
                              : Icons.add_task_rounded,
                          color: PRIMARY_COLOR,
                          size: 24.sp,
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _esEdicion ? 'Personaliza tu turno' : 'Crea tu turno',
                              style: TextStyle(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.w800,
                                color: textColor,
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              'Nombre, horario y color para reconocerlo en el calendario.',
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: mutedColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20.h),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _turnoField(
                        controller: _abreviaturaController,
                        label: 'Abreviatura',
                        hint: 'Ej. M, N, L',
                        icon: Icons.short_text_rounded,
                        maxLength: 3,
                        onChanged: (_) => setState(() {}),
                      ),
                    ),
                    SizedBox(width: 14.w),
                    Column(
                      children: [
                        Container(
                          width: 66.w,
                          height: 82.h,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surfaceContainerHighest
                                .withValues(alpha: .5),
                            border: Border.all(
                              color: theme.colorScheme.outlineVariant
                                  .withValues(alpha: .5),
                            ),
                            borderRadius: BorderRadius.circular(13.r),
                          ),
                          padding: EdgeInsets.all(7.w),
                          child: Column(
                            children: [
                              Text(
                                '15',
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w700,
                                  color: textColor,
                                ),
                              ),
                              SizedBox(height: 4.h),
                              Container(
                                width: double.infinity,
                                padding: EdgeInsets.symmetric(vertical: 4.h),
                                decoration: BoxDecoration(
                                  color: _color.withValues(alpha: .30),
                                  borderRadius: BorderRadius.circular(6.r),
                                  border: Border.all(
                                    color: previewBorderColor,
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  _abreviaturaController.text
                                          .trim()
                                          .isEmpty
                                      ? '—'
                                      : _abreviaturaController.text
                                          .toUpperCase(),
                                  textAlign: TextAlign.center,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: previewTextColor,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          'Vista previa',
                          style: TextStyle(fontSize: 10.sp, color: mutedColor),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 16.h),
                _turnoField(
                  controller: _tituloController,
                  label: 'Título del turno',
                  hint: 'Ej. Mañana, Noche, Descanso',
                  icon: Icons.work_history_outlined,
                  maxLength: 12,
                  onChanged: (_) => setState(() {}),
                ),
                SizedBox(height: 18.h),
                Text(
                  'Horario',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: textColor.withValues(alpha: .8),
                  ),
                ),
                SizedBox(height: 8.h),
                Row(
                  children: [
                    Expanded(
                      child: _timeTile(
                        label: 'Inicio',
                        value: _inicio,
                        onTap: () => _seleccionarHora(esInicio: true),
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: _timeTile(
                        label: 'Fin',
                        value: _fin,
                        onTap: () => _seleccionarHora(esInicio: false),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 18.h),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(13.w),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest
                        .withValues(alpha: .45),
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 42.w,
                        height: 42.w,
                        decoration: BoxDecoration(
                          color: _color,
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Color del turno',
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w700,
                                color: textColor,
                              ),
                            ),
                            SizedBox(height: 3.h),
                            Text(
                              'Te ayudará a identificarlo rápidamente.',
                              style: TextStyle(fontSize: 11.sp, color: mutedColor),
                            ),
                          ],
                        ),
                      ),
                      OutlinedButton(
                        onPressed: _seleccionarColor,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: PRIMARY_COLOR,
                          side: BorderSide(
                            color: PRIMARY_COLOR.withValues(alpha: .5),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                        child: const Text('Cambiar'),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 24.h),
                SizedBox(
                  width: double.infinity,
                  height: 50.h,
                  child: FilledButton.icon(
                    onPressed: _guardando ? null : _guardar,
                    icon: _guardando
                        ? SizedBox(
                            width: 18.sp,
                            height: 18.sp,
                            child: const CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                        : Icon(_esEdicion
                            ? Icons.check_rounded
                            : Icons.add_rounded),
                    label: Text(
                      _guardando
                          ? 'Guardando…'
                          : (_esEdicion ? 'Guardar cambios' : 'Crear turno'),
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w700,
                      ),
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

  Widget _turnoField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int? maxLength,
    ValueChanged<String>? onChanged,
  }) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final outline = colors.outlineVariant.withValues(alpha: .65);
    final roundedBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(17.r),
      borderSide: BorderSide(color: outline, width: 1),
    );
    return TextField(
      controller: controller,
      maxLength: maxLength,
      onChanged: onChanged,
      textCapitalization: TextCapitalization.sentences,
      style: TextStyle(
        fontSize: 14.sp,
        color: colors.onSurface,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, size: 21.sp, color: PRIMARY_COLOR),
        labelStyle: TextStyle(
          fontSize: 13.sp,
          color: colors.onSurface.withValues(alpha: .72),
        ),
        floatingLabelStyle: TextStyle(
          fontSize: 13.sp,
          color: PRIMARY_COLOR,
          fontWeight: FontWeight.w700,
        ),
        hintStyle: TextStyle(
          fontSize: 13.sp,
          color: colors.onSurface.withValues(alpha: .42),
        ),
        filled: true,
        fillColor: colors.surfaceContainerHighest.withValues(alpha: .32),
        counterText: '',
        contentPadding: EdgeInsets.symmetric(
          horizontal: 16.w,
          vertical: 17.h,
        ),
        border: roundedBorder,
        enabledBorder: roundedBorder,
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(17.r),
          borderSide: BorderSide(color: PRIMARY_COLOR, width: 1.6),
        ),
      ),
    );
  }

  Widget _timeTile({
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final textColor = theme.colorScheme.onSurface;
    return Material(
      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: .48),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14.r),
        side: BorderSide(
          color: theme.colorScheme.outlineVariant.withValues(alpha: .35),
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14.r),
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 13.h),
          child: Row(
            children: [
              Icon(Icons.schedule_rounded, color: PRIMARY_COLOR, size: 21.sp),
              SizedBox(width: 9.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label,
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: textColor.withValues(alpha: .6),
                        )),
                    SizedBox(height: 3.h),
                    Text(
                      value,
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w700,
                        color: textColor,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.edit_outlined,
                  size: 16.sp, color: textColor.withValues(alpha: .5)),
            ],
          ),
        ),
      ),
    );
  }
}
