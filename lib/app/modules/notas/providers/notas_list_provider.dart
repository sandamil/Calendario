import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import 'package:calendario2/app/modules/notas/services/notificaciones_service.dart';
import 'package:calendario2/app/data/local/taskDatabase.dart';
import 'package:calendario2/app/data/model/taskModel.dart';
import 'package:calendario2/app/modules/home/providers/calendar_providers.dart';

class NotasListState {
  final List<Task> notas;
  final String busqueda;
  final bool soloImportantes;
  final bool tutorialVisible;

  const NotasListState({
    this.notas = const [],
    this.busqueda = '',
    this.soloImportantes = false,
    this.tutorialVisible = false,
  });

  List<Task> get notasFiltradas {
    final query = busqueda.trim().toLowerCase();

    final resultado = notas.where((nota) {
      if (soloImportantes && nota.isImportant != true) {
        return false;
      }

      if (query.isNotEmpty) {
        final titulo = (nota.title ?? '').toLowerCase();
        if (!titulo.contains(query)) return false;
      }

      return true;
    }).toList();

    resultado.sort((a, b) {
      return (b.startTimeMilliseconds ?? 0)
          .compareTo(a.startTimeMilliseconds ?? 0);
    });

    return resultado;
  }

  NotasListState copyWith({
    List<Task>? notas,
    String? busqueda,
    bool? soloImportantes,
    bool? tutorialVisible,
  }) {
    return NotasListState(
      notas: notas ?? this.notas,
      busqueda: busqueda ?? this.busqueda,
      soloImportantes: soloImportantes ?? this.soloImportantes,
      tutorialVisible: tutorialVisible ?? this.tutorialVisible,
    );
  }
}

class NotasListNotifier extends Notifier<NotasListState> {
  @override
  NotasListState build() => const NotasListState();

  Future<void> reload() async {
    final notas = await NotasDB.instance.getNotesFromDB();
    state = state.copyWith(notas: List<Task>.unmodifiable(notas));
  }

  Future<void> actualizarNota(Task nota) async {
    // Si falla la escritura en SQLite, el error se propaga.
    await NotasDB.instance.update(nota);

    // La actualización ya se guardó: los fallos de refresco
    // se registran por separado.
    try {
      await reload();
    } catch (error, stackTrace) {
      debugPrint(
        'La nota ${nota.id} se actualizó, pero falló la recarga de la lista: $error',
      );
      debugPrintStack(stackTrace: stackTrace);
    }

    try {
      await ref.read(notasProvider.notifier).reload();
    } catch (error, stackTrace) {
      debugPrint(
        'La nota ${nota.id} se actualizó, pero falló la recarga del calendario: $error',
      );
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  Future<void> eliminarNota(int id) async {
    Task? nota;

    try {
      nota = await NotasDB.instance.select(id);
    } catch (error) {
      debugPrint(
        'No se pudo recuperar la nota $id antes de eliminarla: $error',
      );
    }

    final alarmaId = nota?.idAlarma ?? nota?.id ?? id;

    try {
      await NotificacionesService.instance.cancelar(alarmaId);
    } catch (error, stackTrace) {
      debugPrint(
        'No se pudo cancelar el recordatorio de la nota $id: $error',
      );
      debugPrintStack(stackTrace: stackTrace);
    }

    // Si el borrado falla, el error debe propagarse.
    await NotasDB.instance.delete(id);

    // El borrado ya se completó: un fallo de refresco no debe
    // confundirse con un fallo al eliminar el registro.
    try {
      await reload();
    } catch (error, stackTrace) {
      debugPrint(
        'La nota $id se eliminó, pero falló la recarga de la lista: $error',
      );
      debugPrintStack(stackTrace: stackTrace);
    }

    try {
      await ref.read(notasProvider.notifier).reload();
    } catch (error, stackTrace) {
      debugPrint(
        'La nota $id se eliminó, pero falló la recarga del calendario: $error',
      );
      debugPrintStack(stackTrace: stackTrace);
    }
  }
  void setBusqueda(String value) {
    state = state.copyWith(busqueda: value);
  }

  void limpiarBusqueda() {
    state = state.copyWith(busqueda: '');
  }

  void toggleSoloImportantes() {
    state = state.copyWith(
      soloImportantes: !state.soloImportantes,
    );
  }

  void setTutorialVisible(bool visible) {
    state = state.copyWith(tutorialVisible: visible);
  }
}

final notasListProvider =
    NotifierProvider<NotasListNotifier, NotasListState>(
  NotasListNotifier.new,
);
