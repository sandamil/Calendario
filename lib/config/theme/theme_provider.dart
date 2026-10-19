import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/data/local/my_shared_pref.dart';

class ThemeModeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() {
    return MySharedPref.getThemeIsLight()
        ? ThemeMode.light
        : ThemeMode.dark;
  }

  Future<void> setMode(ThemeMode mode) async {
    if (mode == ThemeMode.system || state == mode) return;

    await MySharedPref.setThemeIsLight(mode == ThemeMode.light);
    state = mode;
  }

  Future<void> toggle() {
    final nextMode =
        state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    return setMode(nextMode);
  }
}

final themeModeProvider =
    NotifierProvider<ThemeModeNotifier, ThemeMode>(
  ThemeModeNotifier.new,
);
