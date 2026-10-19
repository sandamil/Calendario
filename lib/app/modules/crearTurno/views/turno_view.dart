import 'package:calendario2/app/controllers/ads_provider.dart';
import 'dart:io';

import 'package:calendario2/config/theme/my_colors.dart';
import 'package:calendario2/config/theme/my_fonts.dart';
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

    return PopScope(
      canPop: !Platform.isAndroid,
      onPopInvokedWithResult: (bool didPop, Object? result) {
        if (didPop) return;
        if (Platform.isAndroid) {
          _volverInicio(context, ref);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          centerTitle: false,
          leading: IconButton(
            icon: Icon(
              Icons.home,
              color: PRIMARY_COLOR,
              size: 26.sp,
            ),
            onPressed: () => _volverInicio(context, ref),
          ),
          title: Text(
            'Tipos de Días',
            style: CustomTextStyle.appBarTitle(context: context),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.only(top: 5),
          child: turnosAsync.when(
            loading: () => const Center(
              child: CircularProgressIndicator(),
            ),
            error: (error, stackTrace) => Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'No se pudieron cargar los tipos de días.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () => ref.invalidate(turnoTypesProvider),
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              ),
            ),
            data: (turnos) {
              if (turnos.isEmpty) {
                return const Center(
                  child: Text('No hay tipos de días creados.'),
                );
              }

              return ListView.builder(
                itemCount: turnos.length,
                itemBuilder: (context, index) {
                  final turno = turnos[index];

                  return Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: HexColor(turno.color!),
                      border: Border.all(width: 0.8),
                      borderRadius: BorderRadius.circular(5.r),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black45,
                          offset: Offset(0, 1),
                          blurRadius: 3,
                        ),
                      ],
                    ),
                    margin: const EdgeInsets.only(
                      top: 4,
                      left: 5,
                      right: 5,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                turno.description ?? '',
                                style: TextStyle(
                                  fontSize: 19,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context)
                                      .primaryTextTheme
                                      .titleLarge
                                      ?.color,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                'De ${turno.startHour ?? ''} a ${turno.endHour ?? ''}',
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Theme.of(context)
                                      .primaryTextTheme
                                      .titleLarge
                                      ?.color,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.edit,
                            color: Theme.of(context)
                                .primaryTextTheme
                                .titleLarge
                                ?.color,
                          ),
                          onPressed: () {
                            context.push('/edit-turno', extra: turno);
                          },
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.delete,
                            color: Theme.of(context)
                                .primaryTextTheme
                                .titleLarge
                                ?.color,
                          ),
                          onPressed: () async {
                            final id = turno.id;
                            if (id == null) return;

                            final notifier =
                                ref.read(turnoTypesProvider.notifier);
                            await notifier.deleteById(id);

                            if (!context.mounted) return;

                            final resultado = ref.read(turnoTypesProvider);
                            if (resultado.hasError) {
                              final error = resultado.error;
                              await notifier.reload();

                              if (!context.mounted) return;

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'No se pudo eliminar el tipo de turno: $error',
                                  ),
                                ),
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5.r),
          ),
          heroTag: 'botonAddTurno',
          onPressed: () {
            context.push('/add-turno');
          },
          icon: const Icon(Icons.add),
          label: const Text('Añadir'),
          backgroundColor: Theme.of(context).primaryColor,
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      ),
    );
  }
}
