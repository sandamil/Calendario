import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum Axiss {
  horizontal,
  vertical,
}

final orientationProvider = NotifierProvider<OrientationNotifier, List<Axiss>?>(
  OrientationNotifier.new,
);

class OrientationNotifier extends Notifier<List<Axiss>?> {
  @override
  List<Axiss>? build() => null;

  void setOverride(List<Axiss>? orientations) {
    state = orientations == null ? null : List<Axiss>.from(orientations);
    _applyOrientation();
  }

  Future<void> _applyOrientation() async {
    final axes = state ?? const [Axiss.vertical, Axiss.horizontal];
    final orientations = <DeviceOrientation>[];

    if (axes.contains(Axiss.vertical)) {
      orientations.addAll([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
    }

    if (axes.contains(Axiss.horizontal)) {
      orientations.addAll([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    }

    await SystemChrome.setPreferredOrientations(orientations);
  }
}
