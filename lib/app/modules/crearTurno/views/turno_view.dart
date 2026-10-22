import 'package:flutter/foundation.dart';
import 'package:calendario2/app/controllers/ads_provider.dart';
import 'package:calendario2/config/theme/my_colors.dart';
import 'package:calendario2/config/util/hexColor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../home/providers/calendar_providers.dart';

class TurnoView extends ConsumerWidget {
  const TurnoView({super.key});
  void _volverInicio(BuildContext context, WidgetRef ref) {
    ref.read(adsProvider.notifier).ensureHomeBanner();
    context.go('/home');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final turnosAsync = ref.watch(turnoTypesProvider);
    final theme = Theme.of(context);
    final text = theme.colorScheme.onSurface;
    return PopScope(
      canPop: !(!kIsWeb && defaultTargetPlatform == TargetPlatform.android),
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && !kIsWeb && defaultTargetPlatform == TargetPlatform.android) _volverInicio(context, ref);
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(tooltip: 'Volver al calendario', icon: Icon(Icons.arrow_back_rounded, color: PRIMARY_COLOR, size: 25.sp), onPressed: () => _volverInicio(context, ref)),
          title: const Text('Tipos de turno'),
        ),
        body: turnosAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) => Center(
            child: Padding(
              padding: EdgeInsets.all(24.w),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.cloud_off_rounded, size: 42.sp, color: text.withOpacity(.45)),
                SizedBox(height: 10.h),
                const Text('No se pudieron cargar los tipos de turno.', textAlign: TextAlign.center),
                SizedBox(height: 8.h),
                FilledButton.tonal(onPressed: () => ref.invalidate(turnoTypesProvider), child: const Text('Reintentar')),
              ]),
            ),
          ),
          data: (turnos) {
            if (turnos.isEmpty) {
              return Center(
                child: Padding(
                  padding: EdgeInsets.all(28.w),
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.work_history_outlined, size: 52.sp, color: PRIMARY_COLOR.withOpacity(.75)),
                    SizedBox(height: 12.h),
                    Text('Todavía no tienes tipos de turno', style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.w800, color: text)),
                    SizedBox(height: 6.h),
                    Text('Crea tus horarios habituales para añadirlos después al calendario.', textAlign: TextAlign.center, style: TextStyle(fontSize: 13.sp, color: text.withOpacity(.62))),
                    SizedBox(height: 16.h),
                    FilledButton.icon(onPressed: () => context.push('/add-turno'), icon: const Icon(Icons.add_rounded), label: const Text('Crear turno')),
                  ]),
                ),
              );
            }
            return ListView.separated(
              padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 100.h),
              itemCount: turnos.length,
              separatorBuilder: (_, __) => SizedBox(height: 10.h),
              itemBuilder: (context, index) {
                final turno = turnos[index];
                final color = HexColor(turno.color ?? '#607D8B');
                final fg = color.computeLuminance() > .52 ? Colors.black87 : Colors.white;
                return Container(
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(color: theme.colorScheme.outlineVariant.withOpacity(.45)),
                    boxShadow: [BoxShadow(color: theme.shadowColor.withOpacity(.04), blurRadius: 12, offset: const Offset(0, 4))],
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(12.w),
                    child: Row(children: [
                      Container(width: 48.w, height: 48.w, alignment: Alignment.center, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(15.r)), child: Text((turno.title ?? '').toUpperCase(), maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: fg, fontSize: 13.sp, fontWeight: FontWeight.w900))),
                      SizedBox(width: 12.w),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(turno.description ?? 'Turno', maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w800, color: text)),
                        SizedBox(height: 5.h),
                        Row(children: [Icon(Icons.schedule_rounded, size: 15.sp, color: text.withOpacity(.58)), SizedBox(width: 5.w), Text('${turno.startHour ?? '--:--'} – ${turno.endHour ?? '--:--'}', style: TextStyle(fontSize: 12.sp, color: text.withOpacity(.65)))]),
                      ])),
                      IconButton(tooltip: 'Editar turno', onPressed: () => context.push('/edit-turno', extra: turno), icon: const Icon(Icons.edit_outlined), color: PRIMARY_COLOR),
                      IconButton(
                        tooltip: 'Eliminar turno',
                        onPressed: () async {
                          final id = turno.id;
                          if (id == null) return;
                          final notifier = ref.read(turnoTypesProvider.notifier);
                          await notifier.deleteById(id);
                          if (!context.mounted) return;
                          final result = ref.read(turnoTypesProvider);
                          if (result.hasError) {
                            final error = result.error;
                            await notifier.reload();
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('No se pudo eliminar el tipo de turno: $error')));
                          }
                        },
                        icon: const Icon(Icons.delete_outline_rounded),
                        color: text.withOpacity(.55),
                      ),
                    ]),
                  ),
                );
              },
            );
          },
        ),
        floatingActionButton: FloatingActionButton.extended(heroTag: 'botonAddTurno', onPressed: () => context.push('/add-turno'), icon: const Icon(Icons.add_rounded), label: const Text('Crear turno')),
      ),
    );
  }
}
