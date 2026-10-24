
import 'package:calendario2/app/modules/home/widgets/calendar/widget/line.dart';
import 'package:calendario2/app/controllers/tutorial_provider.dart';
import 'package:calendario2/app/modules/notas/providers/add_nota_provider.dart';
import 'package:calendario2/app/data/local/my_shared_pref.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:calendario2/app/modules/notas/views/alarmas/views/widget/alarmTile.dart';
import 'package:calendario2/config/theme/my_colors.dart';
import 'package:calendario2/config/theme/my_fonts.dart';
import 'package:calendario2/config/util/app_utils.dart';
import 'package:calendario2/config/util/dateUtils.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';


import '../../../../../../config/util/app_icons.dart';

class AddNotasView extends ConsumerStatefulWidget {
  const AddNotasView({super.key, this.routeArguments});

  final Object? routeArguments;

  @override
  ConsumerState<AddNotasView> createState() => _AddNotasViewState();
}

class _AddNotasViewState extends ConsumerState<AddNotasView> {
  bool _tutorialStartScheduled = false;
  bool _savingNote = false;
  @override
  void initState() {
    super.initState();

    final arguments = widget.routeArguments;

    if (arguments is DateTime) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ref.read(addNotaProvider.notifier).setInitialDate(arguments);
        }
      });
    } else if (arguments is int) {
      final date = DateTime.fromMillisecondsSinceEpoch(arguments);

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ref.read(addNotaProvider.notifier).setInitialDate(date);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final notaState = ref.watch(addNotaProvider);
    final notaNotifier = ref.read(addNotaProvider.notifier);

    var theme = Theme.of(context);
    final tutorialController = ProviderScope.containerOf(
      context,
      listen: false,
    ).read(tutorialControllerProvider);

    if (!_tutorialStartScheduled && MySharedPref.getTutoAddTaskFirst()) {
      _tutorialStartScheduled = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!context.mounted) return;
        notaNotifier.setFirstTime(true);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!context.mounted) return;
          tutorialController.firstInstall(
            'taskAdd',
            context: context,
            onFinished: () => notaNotifier.setFirstTime(false),
          );
        });
      });
    }

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: AppUtils.dismissKeyboard,
      child: Scaffold(
        appBar: AppBar(
          centerTitle: false,
          elevation: 0,
          toolbarHeight: 58.h,
          titleSpacing: 2.w,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          title: Text(
            'Añadir Nota',
            style: CustomTextStyle.appBarTitle(context: context),
          ),
          leading: IconButton(
              icon: Icon(
                Icons.clear,
                color: PRIMARY_COLOR,
                size: 26.sp,
              ),
              onPressed: () async {
                // adcontroller.loadNotesListBannerAd();

                context.go('/notas');
              }),
          actions: <Widget>[
            IconButton(
              icon: Icon(
                Icons.check,
                color: PRIMARY_COLOR,
                size: 26.sp,
              ),
              padding: EdgeInsets.only(right: 3.w),
              onPressed: _savingNote ? null : () async {
                setState(() => _savingNote = true);
                // adcontroller.loadNotesListBannerAd();

                // controller.addTravelEvent();
                final notaNotifier = ProviderScope.containerOf(
                  context,
                  listen: false,
                ).read(addNotaProvider.notifier);

                try {
                  final saved = await notaNotifier.saveNota(
                    id: notaState.idGenerated,
                  );

                  if (!mounted) return;

                  if (saved) {
                    context.go('/notas');
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'No se ha podido guardar la nota. '
                          'Prueba de nuevo.',
                        ),
                      ),
                    );
                  }
                } catch (error) {
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error al guardar la nota: $error'),
                    ),
                  );
                } finally {
                  if (mounted) setState(() => _savingNote = false);
                }
              },
            )
          ],
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Container(
                  key: notaState.firstTime
                      ? tutorialController.keyButton13
                      : null,
                  child: _buildGeneralFormField(
                      notaNotifier.title, 'Titulo del evento', 1),
                ),
                SizedBox(
                  height: 4.h,
                ),
                Column(
                  key: notaState.firstTime
                      ? tutorialController.keyButton17
                      : null,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildGeneralFormField(notaNotifier.site, 'Ubicación', 2),
                    SizedBox(
                      height: 4.h,
                    ),
                    _buildGeneralFormField(
                        notaNotifier.notes, 'Observaciones', 8),
                  ],
                ),
                SizedBox(
                  height: 10.h,
                ),
                Column(
                  key: notaState.firstTime
                      ? tutorialController.keyButton14
                      : null,
                  children: <Widget>[
                    TextButton(
                      onPressed: () async {
                        final initial = notaState.startTime;
                        final selected = await showDatePicker(
                          context: context,
                          initialDate: initial,
                          firstDate: DateTime(1900),
                          lastDate: DateTime(2200),
                        );
                        if (!context.mounted || selected == null) return;
                        final updated = DateTime(
                          selected.year, selected.month, selected.day,
                          initial.hour, initial.minute,
                        );
                        notaNotifier.setStartTime(updated);
                        if (notaState.endTime.isBefore(updated)) {
                          notaNotifier.setEndTime(updated);
                        }
                      },
                      child: _dateTimeRow(
                        'Fecha de inicio',
                        notaState.startTime.formatDateYMD,
                      ),
                    ),
                    TextButton(
                      onPressed: () async {
                        final initial = notaState.startTime;
                        final selected = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.fromDateTime(initial),
                        );
                        if (!context.mounted || selected == null) return;
                        final updated = DateTime(
                          initial.year,
                          initial.month,
                          initial.day,
                          selected.hour,
                          selected.minute,
                        );
                        notaNotifier.setStartTime(updated);
                      },
                      child: _dateTimeRow(
                        'Hora de inicio',
                        notaState.startTime.formatDateTime24H,
                      ),
                    ),
                    TextButton(
                      onPressed: () async {
                        final initial = notaState.endTime;
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
                        if (updated.isBefore(notaState.startTime)) {
                          updated = notaState.startTime;
                        }
                        notaNotifier.setEndTime(updated);
                      },
                      child: _dateTimeRow(
                        'Fecha de fin',
                        notaState.endTime.formatDateYMD,
                      ),
                    ),
                    TextButton(
                      onPressed: () async {
                        final initial = notaState.endTime;
                        final selected = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.fromDateTime(initial),
                        );
                        if (!context.mounted || selected == null) return;
                        var updated = DateTime(
                          initial.year, initial.month, initial.day,
                          selected.hour, selected.minute,
                        );
                        if (updated.isBefore(notaState.startTime)) {
                            final start = notaState.startTime;
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
                        notaNotifier.setEndTime(updated);
                      },
                      child: _dateTimeRow(
                        'Hora de fin',
                        notaState.endTime.formatDateTime24H,
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 2.h,
                ),
                LineWidget(),
                TextButton(
                    onPressed: () async {
                      var selectedAlertTime = notaState.alarmaCreada
                          ? notaState.alarmTime
                          : notaState.startTime;
                      var selectedMode = notaState.notificationMode;
                      var reminderEnabled = notaState.alarmaCreada;
                      final result = await showDialog<Map<String, dynamic>>(
                        context: context,
                        builder: (dialogContext) => StatefulBuilder(
                          builder: (dialogContext, setDialogState) => AlertDialog(
                            title: const Text('Recordatorio'),
                            content: SingleChildScrollView(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SwitchListTile(
                                    contentPadding: EdgeInsets.zero,
                                    title: const Text('Activar recordatorio'),
                                    value: reminderEnabled,
                                    onChanged: (value) => setDialogState(
                                      () => reminderEnabled = value,
                                    ),
                                  ),
                                  if (reminderEnabled) ...[
                                    const SizedBox(height: 12),
                                    const Text('Hora del aviso'),
                                    const SizedBox(height: 8),
                                    SizedBox(
                                      width: double.infinity,
                                      child: OutlinedButton.icon(
                                        icon: const Icon(Icons.access_time),
                                        label: Text(
                                          TimeOfDay(
                                            hour: selectedAlertTime.hour,
                                            minute: selectedAlertTime.minute,
                                          ).format(dialogContext),
                                        ),
                                        onPressed: () async {
                                          final selected = await showTimePicker(
                                            context: dialogContext,
                                            initialTime: TimeOfDay.fromDateTime(
                                              selectedAlertTime,
                                            ),
                                          );
                                          if (selected == null) return;
                                          setDialogState(() {
                                            selectedAlertTime = DateTime(
                                              notaState.startTime.year,
                                              notaState.startTime.month,
                                              notaState.startTime.day,
                                              selected.hour,
                                              selected.minute,
                                            );
                                          });
                                        },
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    const Text('Tipo de aviso'),
                                    const SizedBox(height: 8),
                                    SegmentedButton<String>(
                                      showSelectedIcon: false,
                                      segments: const <ButtonSegment<String>>[
                                        ButtonSegment<String>(
                                          value: 'notificacion',
                                          label: Text('Notificación'),
                                          icon: Icon(Icons.notifications_outlined),
                                        ),
                                        ButtonSegment<String>(
                                          value: 'alarma',
                                          label: Text('Alarma'),
                                          icon: Icon(Icons.alarm_rounded),
                                        ),
                                      ],
                                      selected: <String>{selectedMode},
                                      onSelectionChanged: (selection) {
                                        setDialogState(
                                          () => selectedMode = selection.first,
                                        );
                                      },
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      selectedMode == 'alarma'
                                          ? 'Aviso con canal de alarma independiente.'
                                          : 'Notificación normal con el sonido del móvil.',
                                      style: TextStyle(
                                        fontSize: 12.sp,
                                        color: Theme.of(dialogContext)
                                            .colorScheme
                                            .onSurface
                                            .withValues(alpha: .65),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(dialogContext).pop(),
                                child: const Text('Cancelar'),
                              ),
                              FilledButton(
                                onPressed: () => Navigator.of(dialogContext).pop({
                                  'enabled': reminderEnabled,
                                  'time': selectedAlertTime,
                                  'mode': selectedMode,
                                }),
                                child: const Text('Guardar'),
                              ),
                            ],
                          ),
                        ),
                      );
                      if (!context.mounted || result == null) return;
                      final enabled = result['enabled'] as bool;
                      notaNotifier.setAlarmaCreada(enabled);
                      notaNotifier.setNotificationMode(result['mode'] as String);
                      if (enabled) {
                        final alertTime = result['time'] as DateTime;
                        notaNotifier.setAlarmaTime(alertTime);
                        notaNotifier.setAlarmaActivadaString(
                          'A las ${TimeOfDay(hour: alertTime.hour, minute: alertTime.minute).format(context)}',
                        );
                      } else {
                        notaNotifier.setAlarmaActivadaString('Sin recordatorio');
                      }
                    },
                    child: Row(
                        key: notaState.firstTime
                            ? tutorialController.keyButton15
                            : null,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Text('Recordatorio',
                              style: CustomTextStyle.rowButomText),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Text(
                                notaState.alarmaActivadaString,
                                style: TextStyle(
                                    color: MyColors.textButtomBlack,
                                    fontSize: 16.sp),
                              ),
                              Icon(
                                Icons.arrow_forward_ios,
                                size: 16.sp,
                                color: PRIMARY_COLOR,
                              )
                            ],
                          )
                        ])),
                notaState.alarmaCreada
                    ? ExampleAlarmTile(
                        key: Key(notaState.alarmTime.toString()),
                        title: TimeOfDay(
                          hour: notaState.alarmTime.hour,
                          minute: notaState.alarmTime.minute,
                        ).format(context),
                        onPressed: () {
                          null;
                          // navigateToAlarmScreen(
                          //     notaState.alarmaCreadaNota, context);
                        },
                      )
                    : Container(),
                // : Container(child: Text(notaState.alarmTime.toString()),),
                LineWidget(),
                SizedBox(
                  height: 2.h,
                ),
                TextButton(
                    key: notaState.firstTime
                        ? tutorialController.keyButton16
                        : null,
                    onPressed: notaNotifier.toggleImportant,
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Text('Marcar como importante',
                              style: CustomTextStyle.rowButomText),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Icon(
                                notaState.isImportant
                                    ? Icons.flag
                                    : Icons.outlined_flag,
                                color: notaState.isImportant
                                    ? Colors.red
                                    : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.65),
                              )
                            ],
                          )
                        ])),
                Container(
                  padding: EdgeInsets.only(left: 8.w, top: 16.h),
                  child: Row(
                    children: <Widget>[
                      Text(
                        "Pulsa aqui si necesitas ayuda para crear notas.",
                        style: TextStyle(
                          fontSize: 12.sp,
                        ),
                      ),
                      IconButton(
                        key: notaState.firstTime
                            ? tutorialController.keyNotasAyuda
                            : null,
                        icon: const AppIcon(AppIcons.informacion,
                            color: Colors.green),
                        tooltip: '',
                        onPressed: () {
                          notaNotifier.setFirstTime(true);
                          tutorialController.showTutorial(
                            context,
                            'taskAdd',
                            onFinished: () => notaNotifier.setFirstTime(false),
                          );
                        },
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

  Future<dynamic> buildDialogAlarma(
      BuildContext context, ThemeData theme, AddNotaState notaState, AddNotaNotifier notaNotifier) {
    return showDialog(context: context, builder: (context) => Align(
      alignment: Alignment.center,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 10.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w),
              decoration: BoxDecoration(
                color: theme.scaffoldBackgroundColor,
                borderRadius: BorderRadius.all(
                  Radius.circular(5.r),
                ),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.all(8.h),
                    child: AppIcon(
                      AppIcons.informacion,
                      color: Colors.green,
                      size: 38.sp,
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(6.h),
                    color: theme.scaffoldBackgroundColor,
                    height: 100.h,
                    child: Padding(
                      padding: EdgeInsets.all(4.h),
                      child: Text(
                        'Tienes una alarma creada en esta nota para las: '
                        '${notaState.alarmaHora}'
                        //     '${TimeOfDay(
                        //   hour: controller
                        //       .alarmaCreadaNota!
                        //       .dateTime
                        //       .hour,
                        //   minute: controller
                        //       .alarmaCreadaNota!
                        //       .dateTime
                        //       .minute,
                        // ).format(context)}'
                        ''
                        ', quieres borrarla?',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            context.pop();
                            // Get.toNamed('/add-notas', arguments: selectedDate);
                          },
                          child: const Text("Cancelar"),
                        ),
                      ),
                      SizedBox(
                        width: 8.w,
                      ),
                      Expanded(
                          child: ElevatedButton(
                        onPressed: () {
                          notaNotifier.setAlarmaCreada(false);
                          notaNotifier.setAlarmaActivadaString(
                            'Sin recordatorio',
                          );
                          notaNotifier.setAlarmaTime(notaState.startTime);
                          context.pop();
                        },
                        child: const Text("Borrar"),
                      )),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ));
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
    TextEditingController value,
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
            style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w700, color: textColor.withValues(alpha: .72)),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: .48),
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: theme.colorScheme.outlineVariant.withValues(alpha: .38)),
          ),
          child: TextFormField(
            controller: value,
            maxLines: lines,
            minLines: lines > 1 ? (lines < 3 ? lines : 3) : 1,
            textCapitalization: TextCapitalization.sentences,
            style: TextStyle(fontSize: 14.sp, color: textColor),
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: PRIMARY_COLOR, size: 20.sp),
              hintText: hint,
              hintStyle: TextStyle(fontSize: 13.sp, color: textColor.withValues(alpha: .42)),
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
}
