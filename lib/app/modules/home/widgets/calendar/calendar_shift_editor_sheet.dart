import 'package:flutter/material.dart';

import '../../../../components/ad_banner_slot.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../config/theme/my_colors.dart';
import '../../../../data/model/cuadranteDay.dart';
import '../../utils/shift_time_utils.dart';

class CalendarShiftEditorSheet extends StatefulWidget {
  const CalendarShiftEditorSheet({required this.shift, super.key});

  final CuadranteDay shift;

  @override
  State<CalendarShiftEditorSheet> createState() =>
      _CalendarShiftEditorSheetState();
}

class _CalendarShiftEditorSheetState extends State<CalendarShiftEditorSheet> {
  static const _colors = <String>[
    '#4287f5',
    '#71bd48',
    '#bd9648',
    '#9c27b0',
    '#ef5350',
    '#607D8B',
    '#009688',
    '#ff9800',
    '#455a64',
    '#ffffff',
  ];

  late final TextEditingController _title;
  late final TextEditingController _description;
  late String _start;
  late String _end;
  late String _color;

  @override
  void initState() {
    super.initState();
    _title = TextEditingController(text: widget.shift.title ?? '');
    _description = TextEditingController(text: widget.shift.description ?? '');
    _start = widget.shift.startHour ?? '07:00';
    _end = widget.shift.endHour ?? '15:00';
    _color = widget.shift.color ?? '#607D8B';
  }

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    super.dispose();
  }

  TimeOfDay _parseTime(String value) {
    final parts = value.split(':');
    return TimeOfDay(
      hour: int.tryParse(parts.first) ?? 7,
      minute: int.tryParse(parts.length > 1 ? parts[1] : '') ?? 0,
    );
  }

  Future<void> _pickTime(bool start) async {
    final selected = await showTimePicker(
      context: context,
      initialTime: _parseTime(start ? _start : _end),
      helpText: start ? 'Hora de inicio' : 'Hora de fin',
      initialEntryMode: TimePickerEntryMode.input,
    );
    if (selected == null || !mounted) return;
    final value =
        '${selected.hour.toString().padLeft(2, '0')}:${selected.minute.toString().padLeft(2, '0')}';
    setState(() {
      if (start) {
        _start = value;
      } else {
        _end = value;
      }
    });
  }

  void _save() {
    final duration = ShiftTimeUtils.durationMinutes(_start, _end);
    if (duration == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'La hora de fin debe ser distinta de la hora de inicio.',
          ),
        ),
      );
      return;
    }
    final title = _title.text.trim();
    final description = _description.text.trim();
    if (title.isEmpty || description.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Completa el nombre y la descripción del turno.'),
        ),
      );
      return;
    }
    Navigator.of(context).pop(
      CuadranteDay(
        id: widget.shift.id,
        cuadranteName: widget.shift.cuadranteName,
        title: title,
        description: description,
        startHour: _start,
        endHour: _end,
        color: _color,
        dateTime: widget.shift.dateTime,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColor = theme.colorScheme.onSurface;
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: Material(
        color: theme.scaffoldBackgroundColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(26.r)),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(18.w, 12.h, 18.w, 20.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 38.w,
                    height: 4.h,
                    decoration: BoxDecoration(
                      color: textColor.withValues(alpha: .2),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                  ),
                ),
                SizedBox(height: 16.h),
                Text(
                  'Editar turno del calendario',
                  style: TextStyle(
                    fontSize: 19.sp,
                    fontWeight: FontWeight.w800,
                    color: textColor,
                  ),
                ),
                SizedBox(height: 14.h),
                TextField(
                  controller: _title,
                  maxLength: 3,
                  decoration: const InputDecoration(
                    labelText: 'Abreviatura',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 8.h),
                TextField(
                  controller: _description,
                  decoration: const InputDecoration(
                    labelText: 'Nombre del turno',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 14.h),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _pickTime(true),
                        icon: const Icon(Icons.login_rounded),
                        label: Text('Inicio  $_start'),
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _pickTime(false),
                        icon: const Icon(Icons.logout_rounded),
                        label: Text('Fin  $_end'),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 15.h),
                Text(
                  'Color del turno',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: textColor,
                  ),
                ),
                SizedBox(height: 8.h),
                Wrap(
                  spacing: 10.w,
                  runSpacing: 9.h,
                  children: [
                    for (final color in _colors)
                      InkWell(
                        onTap: () => setState(() => _color = color),
                        customBorder: const CircleBorder(),
                        child: Container(
                          width: 34.w,
                          height: 34.w,
                          decoration: BoxDecoration(
                            color: Color(
                              int.parse(color.replaceFirst('#', '0xFF')),
                            ),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: _color == color
                                  ? theme.colorScheme.primary
                                  : theme.colorScheme.outlineVariant,
                              width: _color == color ? 3 : 1,
                            ),
                          ),
                          child: _color == color
                              ? Icon(
                                  Icons.check_rounded,
                                  size: 17.sp,
                                  color: color == '#ffffff'
                                      ? Colors.black
                                      : Colors.white,
                                )
                              : null,
                        ),
                      ),
                  ],
                ),
                SizedBox(height: 20.h),
                SizedBox(
                  width: double.infinity,
                  height: 48.h,
                  child: FilledButton.icon(
                    onPressed: _save,
                    icon: const Icon(Icons.save_rounded),
                    label: const Text('Guardar cambios'),
                    style: FilledButton.styleFrom(
                      backgroundColor: PRIMARY_COLOR,
                    ),
                  ),
                ),
                const AdBannerSlot(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
