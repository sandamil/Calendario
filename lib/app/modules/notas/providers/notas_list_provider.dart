import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:calendario2/app/data/local/taskDatabase.dart';
import 'package:calendario2/app/data/model/taskModel.dart';

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
