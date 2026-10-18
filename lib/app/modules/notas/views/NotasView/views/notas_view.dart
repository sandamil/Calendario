import 'package:calendario2/app/components/toast.dart';
import 'package:calendario2/app/data/local/taskDatabase.dart';
import 'package:calendario2/app/data/model/taskModel.dart';
import 'package:calendario2/app/modules/home/providers/calendar_providers.dart';
import 'package:calendario2/app/modules/notas/providers/notas_list_provider.dart';
import 'package:calendario2/config/theme/my_colors.dart';
import 'package:calendario2/config/theme/my_fonts.dart';
import 'package:calendario2/config/util/dateUtils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';

class NotasView extends ConsumerStatefulWidget {
  const NotasView({Key? key}) : super(key: key);

  @override
  ConsumerState<NotasView> createState() => _NotasViewState();
}

class _NotasViewState extends ConsumerState<NotasView> {
  late Task _note;
  bool _headerVisible = false;
  bool _deleting = false;

  @override
  void initState() {
    super.initState();

    final args = Get.arguments;
    final noteData = args is Map ? args['noteData'] : null;

    if (noteData is Task) {
      _note = noteData;
    } else {
      _note = Task();
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() => _headerVisible = true);
    });
  }

  DateTime? get _start {
    final value = _note.startTimeMilliseconds;
    return value == null ? null : DateTime.fromMillisecondsSinceEpoch(value);
  }

  DateTime? get _end {
    final value = _note.endTimeMilliseconds;
    return value == null ? null : DateTime.fromMillisecondsSinceEpoch(value);
  }

  String _dateTime(DateTime? value) =>
      value == null ? '—' : value.formatDateTime24H.toString();

  String _date(DateTime? value) =>
      value == null ? '—' : value.formatDateYMMMd.toString();

  Future<void> _toggleImportant() async {
    final id = _note.id;
    if (id == null) {
      Toast.toast(context, msg: 'No se puede actualizar una nota sin ID.');
      return;
    }

    final updated = Task(
      id: _note.id,
      title: _note.title,
      site: _note.site,
      notes: _note.notes,
      startTimeMilliseconds: _note.startTimeMilliseconds,
      endTimeMilliseconds: _note.endTimeMilliseconds,
      isImportant: !(_note.isImportant ?? false),
      idAlarma: _note.idAlarma,
      alarmaHora: _note.alarmaHora,
      alarmaTimestamp: _note.alarmaTimestamp,
      alarmaActivadaString: _note.alarmaActivadaString,
      isAlarmaCreated: _note.isAlarmaCreated,
    );

    await NotasDB.instance.update(updated);
    if (!mounted) return;

    setState(() {
      _note = updated;
    });
    await ref.read(notasListProvider.notifier).reload();
    await ref.read(notasProvider.notifier).reload();
  }

  Future<void> _shareNote() async {
    final start = _start;
    final end = _end;

    await Share.share(
      'Titulo: ${_note.title ?? ''}'
      '\nNota: ${_note.notes ?? ''}'
      '\nInicio: ${_dateTime(start)} h. ${_date(start)}'
      '\nFin: ${_dateTime(end)} h. ${_date(end)}',
    );
  }

  void _editNote() {
    final id = _note.id;
    if (id == null) {
      Toast.toast(context, msg: 'No se puede editar una nota sin ID.');
      return;
    }

    Get.toNamed(
      '/edit-notas',
      arguments: {'id': id, 'noteData': _note},
    );
  }

  Future<void> _deleteNote() async {
    final id = _note.id;
    if (id == null || _deleting) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        title: const Text('Borrar nota'),
        content: const Text('Se borrará permanentemente'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(
              'CANCELAR',
              style: TextStyle(color: Theme.of(dialogContext).primaryColor),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(
              'BORRAR',
              style: TextStyle(
                color: Colors.red.shade300,
                fontWeight: FontWeight.w500,
                letterSpacing: 1,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _deleting = true);
    try {
      await NotasDB.instance.delete(id);
      await ref.read(notasListProvider.notifier).reload();
      await ref.read(notasProvider.notifier).reload();

      if (!mounted) return;
      Toast.toast(context, msg: 'Eliminado exitosamente!');
      Get.offAllNamed('/notas');
    } finally {
      if (mounted) setState(() => _deleting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final start = _start;
    final end = _end;
    final important = _note.isImportant ?? false;
    final hasAlarm = _note.isAlarmaCreated ?? false;

    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Text(
          'Notas',
          style: CustomTextStyle.appBarTitle(context: context),
          overflow: TextOverflow.visible,
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: PRIMARY_COLOR,
            size: 26.sp,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            tooltip: important ? 'Quitar importancia' : 'Marcar importante',
            icon: Icon(
              important ? Icons.flag : Icons.outlined_flag,
              size: 26.sp,
              color: important ? Colors.red : Colors.black45,
            ),
            onPressed: _toggleImportant,
          ),
          IconButton(
            tooltip: 'Eliminar nota',
            icon: Icon(Icons.delete_outline, color: PRIMARY_COLOR, size: 26.sp),
            onPressed: _deleteNote,
          ),
          IconButton(
            tooltip: 'Compartir nota',
            icon: Icon(Icons.share, color: PRIMARY_COLOR, size: 26.sp),
            onPressed: _shareNote,
          ),
          IconButton(
            tooltip: 'Editar nota',
            icon: Icon(Icons.edit, color: PRIMARY_COLOR, size: 26.sp),
            onPressed: _editNote,
          ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.only(bottom: 24.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(
                    left: 24.w,
                    right: 24.w,
                    top: 24.h,
                    bottom: 16.h,
                  ),
                  child: AnimatedOpacity(
                    opacity: _headerVisible ? 1 : 0,
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeIn,
                    child: Text(
                      _note.title ?? '',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 36.sp,
                      ),
                    ),
                  ),
                ),
                AnimatedOpacity(
                  duration: const Duration(milliseconds: 500),
                  opacity: _headerVisible ? 1 : 0,
                  child: Padding(
                    padding: EdgeInsets.only(left: 24.w),
                    child: Column(
                      children: [
                        _dateRow('Inicio:', start),
                        _dateRow('Fin:    ', end),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(
                    left: 24.w,
                    top: 16.h,
                    bottom: 14.h,
                    right: 24.w,
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        color: PRIMARY_COLOR,
                      ),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: Text(
                          (_note.site == null || _note.site!.isEmpty)
                              ? 'No hay ubicación'
                              : _note.site!,
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w500,
                            color: _note.site == null
                                ? Colors.grey.shade600
                                : null,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(
                    left: 24.w,
                    top: 16.h,
                    bottom: 14.h,
                    right: 24.w,
                  ),
                  child: !hasAlarm
                      ? const Text(
                          'No has añadido alarma',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        )
                      : Row(
                          children: [
                            const Icon(Icons.alarm, color: Colors.redAccent),
                            SizedBox(width: 10.w),
                            Expanded(
                              child: Text(
                                _note.alarmaActivadaString ?? 'Alarma activada',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                ),
                Padding(
                  padding: EdgeInsets.only(
                    left: 24.w,
                    top: 36.h,
                    bottom: 24.h,
                    right: 24.w,
                  ),
                  child: Text(
                    (_note.notes == null || _note.notes!.isEmpty)
                        ? 'No has añadido descripción'
                        : _note.notes!,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (_deleting)
            const Positioned.fill(
              child: ColoredBox(
                color: Color(0x22000000),
                child: Center(child: CircularProgressIndicator()),
              ),
            ),
        ],
      ),
    );
  }

  Widget _dateRow(String label, DateTime? value) {
    return Row(
      children: [
        Padding(
          padding: EdgeInsets.only(right: 10.w),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade600,
            ),
          ),
        ),
        Text(
          _dateTime(value),
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade600,
          ),
        ),
        SizedBox(width: 4.w),
        Text(
          _date(value),
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade600,
          ),
        ),
        const Spacer(),
      ],
    );
  }
}
