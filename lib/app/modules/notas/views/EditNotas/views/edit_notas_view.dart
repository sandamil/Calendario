import 'package:calendario2/app/modules/home/widgets/calendar/widget/line.dart';
import 'package:calendario2/app/modules/notas/providers/edit_nota_provider.dart';
import 'package:calendario2/app/modules/notas/views/alarmas/views/widget/alarmTile.dart';
import 'package:calendario2/config/theme/my_colors.dart';
import 'package:calendario2/config/theme/my_fonts.dart';
import 'package:calendario2/config/util/dateUtils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart'
    as dp;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class EditNotasView extends ConsumerStatefulWidget {
  const EditNotasView({super.key});

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

    final args = Get.arguments;
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

  Future<void> _pickDate({
    required BuildContext context,
    required DateTime initialDate,
    required ValueChanged<DateTime> onChanged,
  }) async {
    dp.DatePicker.showDateTimePicker(
      context,
      theme: dp.DatePickerTheme(
        cancelStyle: TextStyle(
          color: Colors.redAccent.shade200,
          fontSize: 16.sp,
          fontWeight: FontWeight.bold,
        ),
        doneStyle: TextStyle(
          color: MyColors.textColorPrimary,
          fontSize: 16.sp,
          fontWeight: FontWeight.bold,
        ),
        itemStyle: TextStyle(
          color: MyColors.textColorPrimary,
          fontSize: 16.sp,
          fontWeight: FontWeight.bold,
        ),
        backgroundColor: MyColors.backgroundLowAccent,
      ),
      showTitleActions: true,
      onChanged: onChanged,
      onConfirm: (_) {},
      currentTime: initialDate,
      locale: dp.LocaleType.es,
    );
  }

  TextFormField _buildGeneralFormField(
    TextEditingController controller,
    String hint,
    int lines,
  ) {
    final radius = 5.r;

    return TextFormField(
      controller: controller,
      maxLines: lines,
      decoration: InputDecoration(
        filled: true,
        contentPadding: EdgeInsets.only(left: 10.w, top: 20.h),
        fillColor: MyColors.backgroundLowAccent,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(radius)),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(radius)),
          borderSide: BorderSide(
            color: MyColors.borderCellColor,
            width: 2.w,
          ),
        ),
        hintText: hint,
        hintStyle: CustomTextStyle.hintText,
      ),
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
          onPressed: () => Get.offAllNamed('/notas'),
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
                Get.offAllNamed('/notas');
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 6.w),
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
                  onPressed: () {
                    _pickDate(
                      context: context,
                      initialDate: state.startTime,
                      onChanged: (date) {
                        notifier.setStartTime(date);
                        if (state.endTime.isBefore(date)) {
                          notifier.setEndTime(date);
                        }
                      },
                    );
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Hora de inicio',
                        style: CustomTextStyle.rowButomText,
                      ),
                      Row(
                        children: [
                          Text(
                            '${state.startTime.formatDateYMD} '
                            '${state.startTime.formatDateTime24H}',
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
                TextButton(
                  onPressed: () {
                    _pickDate(
                      context: context,
                      initialDate: state.endTime,
                      onChanged: (date) {
                        notifier.setEndTime(
                          date.isBefore(state.startTime)
                              ? state.startTime
                              : date,
                        );
                      },
                    );
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Hora final',
                        style: CustomTextStyle.rowButomText,
                      ),
                      Row(
                        children: [
                          Text(
                            '${state.endTime.formatDateYMD} '
                            '${state.endTime.formatDateTime24H}',
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
                SizedBox(height: 2.h),
                LineWidget(),
                TextButton(
                  onPressed: () {
                    if (state.alarmaCreada) {
                      Get.dialog(
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
                              onPressed: Get.back,
                              child: const Text('Cancelar'),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                Get.back();
                                Get.toNamed(
                                  '/alarmas',
                                  arguments: {
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
                      Get.toNamed(
                        '/alarmas',
                        arguments: {
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
                        color: state.isImportant ? Colors.red : Colors.black45,
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
