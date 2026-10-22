import 'package:calendario2/app/modules/home/widgets/calendar/widget/line.dart';
import 'package:calendario2/app/modules/notas/providers/edit_nota_provider.dart';
import 'package:calendario2/app/modules/notas/views/alarmas/views/widget/alarmTile.dart';
import 'package:calendario2/config/theme/my_colors.dart';
import 'package:calendario2/config/theme/my_fonts.dart';
import 'package:calendario2/config/util/dateUtils.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class EditNotasView extends ConsumerStatefulWidget {
  const EditNotasView({super.key, this.routeArguments});

  final Object? routeArguments;

  @override
  ConsumerState<EditNotasView> createState() => _EditNotasViewState();
}

class _EditNotasViewState extends ConsumerState<EditNotasView> {
  bool _loadStarted = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_loadStarted) return;
    _loadStarted = true;

    final args = widget.routeArguments;
    int? id;

    if (args is Map) {
      final value = args['id'];
      if (value is int) {
        id = value;
      } else if (value is String) {
        id = int.tryParse(value);
      }
    } else if (args is int) {
      id = args;
    }

    if (id == null) {
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.read(editNotaProvider.notifier).load(id!);
      }
    });
  }

  Widget _dateTimeRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(label, style: CustomTextStyle.rowButomText),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              value,
              style: TextStyle(
                color: MyColors.textButtomBlack,
                fontSize: 16.sp,
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16.sp,
              color: PRIMARY_COLOR,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildGeneralFormField(
    TextEditingController controller,
    String label,
    int lines,
  ) {
    final theme = Theme.of(context);
    final textColor = theme.colorScheme.onSurface;
    final lower = label.toLowerCase();
    final icon = lower.contains('ubic')
        ? Icons.location_on_outlined
        : lower.contains('observ')
            ? Icons.notes_rounded
            : Icons.title_rounded;
    final hint = lower.contains('ubic')
        ? 'Añade una ubicación (opcional)'
        : lower.contains('observ')
            ? 'Escribe los detalles que quieras recordar'
            : 'Escribe un título breve';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 3.w, bottom: 6.h),
          child: Text(
            label.replaceFirst('Titulo', 'Título'),
            style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w700, color: textColor.withOpacity(.72)),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest.withOpacity(.48),
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: theme.colorScheme.outlineVariant.withOpacity(.38)),
          ),
          child: TextFormField(
            controller: controller,
            maxLines: lines,
            minLines: lines > 1 ? 3 : 1,
            textCapitalization: TextCapitalization.sentences,
            style: TextStyle(fontSize: 14.sp, color: textColor),
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: PRIMARY_COLOR, size: 20.sp),
              hintText: hint,
              hintStyle: TextStyle(fontSize: 13.sp, color: textColor.withOpacity(.42)),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(vertical: lines > 1 ? 14.h : 15.h),
            ),
          ),
        ),
      ],
    );
  }
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(editNotaProvider);
    final notifier = ref.read(editNotaProvider.notifier);
    final theme = Theme.of(context);

    if (state.loading || state.currentNote == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            'Editar Nota',
            style: CustomTextStyle.appBarTitle(context: context),
          ),
        ),
        body: Center(
          child: state.loading
              ? const CircularProgressIndicator()
              : const Text('No se ha podido cargar la nota.'),
        ),
      );
    }

    final note = state.currentNote!;

    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Text(
          'Editar Nota',
          style: CustomTextStyle.appBarTitle(context: context),
          overflow: TextOverflow.clip,
          softWrap: false,
        ),
        leading: IconButton(
          icon: Icon(
            Icons.clear,
            color: PRIMARY_COLOR,
            size: 26.sp,
          ),
          onPressed: () => context.go('/notas'),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.check,
              color: PRIMARY_COLOR,
              size: 26.sp,
            ),
            padding: EdgeInsets.only(right: 3.w),
            onPressed: () async {
              await notifier.editNote(note);
              if (mounted) {
                context.go('/notas');
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Form(
            child: Column(
              children: [
                SizedBox(height: 10.h),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 6.w),
                  child: _buildGeneralFormField(
                    notifier.title,
                    'Titulo del evento',
                    1,
                  ),
                ),
                SizedBox(height: 4.h),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 6.w),
                  child: _buildGeneralFormField(
                    notifier.site,
                    'Ubicación',
                    2,
                  ),
                ),
                SizedBox(height: 4.h),
                _buildGeneralFormField(
                  notifier.notes,
                  'Observaciones',
                  8,
                ),
                SizedBox(height: 6.h),
                TextButton(
                  onPressed: () async {
                    final initial = state.startTime;
                    final selected = await showDatePicker(
                      context: context,
                      initialDate: initial,
                      firstDate: DateTime(1900),
                      lastDate: DateTime(2200),
                    );
                    if (!context.mounted || selected == null) return;
                    notifier.setStartTime(DateTime(
                      selected.year, selected.month, selected.day,
                      initial.hour, initial.minute,
                    ));
                  },
                  child: _dateTimeRow(
                    'Fecha de inicio',
                    state.startTime.formatDateYMD,
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    final initial = state.startTime;
                    final selected = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.fromDateTime(initial),
                    );
                    if (!context.mounted || selected == null) return;
                    notifier.setStartTime(DateTime(
                      initial.year, initial.month, initial.day,
                      selected.hour, selected.minute,
                    ));
                  },
                  child: _dateTimeRow(
                    'Hora de inicio',
                    state.startTime.formatDateTime24H,
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    final initial = state.endTime;
                    final selected = await showDatePicker(
                      context: context,
                      initialDate: initial,
                      firstDate: DateTime(1900),
                      lastDate: DateTime(2200),
                    );
                    if (!context.mounted || selected == null) return;
                    var updated = DateTime(
                      selected.year, selected.month, selected.day,
                      initial.hour, initial.minute,
                    );
                    if (updated.isBefore(state.startTime)) {
                      updated = state.startTime;
                    }
                    notifier.setEndTime(updated);
                  },
                  child: _dateTimeRow(
                    'Fecha de fin',
                    state.endTime.formatDateYMD,
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    final initial = state.endTime;
                    final selected = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.fromDateTime(initial),
                    );
                    if (!context.mounted || selected == null) return;
                    var updated = DateTime(
                      initial.year, initial.month, initial.day,
                      selected.hour, selected.minute,
                    );
                    if (updated.isBefore(state.startTime)) {
                        final start = state.startTime;
                        updated = DateTime(
                          start.year,
                          start.month,
                          start.day,
                          selected.hour,
                          selected.minute,
                        );
                        if (updated.isBefore(start)) {
                          updated = updated.add(const Duration(days: 1));
                        }
                    }
                    notifier.setEndTime(updated);
                  },
                  child: _dateTimeRow(
                    'Hora de fin',
                    state.endTime.formatDateTime24H,
                  ),
                ),
                SizedBox(height: 2.h),
                LineWidget(),
                TextButton(
                  onPressed: () {
                    if (state.alarmaCreada) {
                      showDialog(context: context, builder: (context) =>
                        AlertDialog(
                          backgroundColor: theme.scaffoldBackgroundColor,
                          title: const Icon(
                            Icons.info,
                            color: Colors.redAccent,
                            size: 38,
                          ),
                          content: const Text(
                            'Puedes modificar o quitar el recordatorio '
                            'de esta nota.',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => context.pop(),
                              child: const Text('Cancelar'),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                context.pop();
                                context.push(
                                  '/alarmas',
                                  extra: {
                                    'isEditing': true,
                                    'currentNota': note,
                                    'currentNote': note,
                                  },
                                );
                              },
                              child: const Text('Modificar'),
                            ),
                          ],
                        ),
                      );
                    } else {
                      context.push(
                        '/alarmas',
                        extra: {
                          'currentNote': note,
                          'currentNota': note,
                          'isEditing': true,
                        },
                      );
                    }
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Recordatorio',
                        style: CustomTextStyle.rowButomText,
                      ),
                      Row(
                        children: [
                          Text(
                            state.alarmaActivadaString,
                            style: TextStyle(
                              color: MyColors.textButtomBlack,
                              fontSize: 16.sp,
                            ),
                          ),
                          Icon(
                            Icons.arrow_forward_ios,
                            size: 16.sp,
                            color: PRIMARY_COLOR,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (state.alarmaCreada)
                  ExampleAlarmTile(
                    key: Key(state.alarmTime.toString()),
                    title: state.alarmaHora,
                    onPressed: () {},
                  ),
                LineWidget(),
                SizedBox(height: 2.h),
                TextButton(
                  onPressed: () {
                    notifier.setImportant(!state.isImportant);
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Marcar como importante',
                        style: CustomTextStyle.rowButomText,
                      ),
                      Icon(
                        state.isImportant ? Icons.flag : Icons.outlined_flag,
                        color: state.isImportant ? Colors.red : Theme.of(context).colorScheme.onSurface.withOpacity(0.65),
                      ),
                    ],
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
