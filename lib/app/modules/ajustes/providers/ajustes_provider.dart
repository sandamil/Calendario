import 'dart:convert';
import 'dart:typed_data';

import 'package:calendario2/app/components/custom_snackbar.dart';
import 'package:calendario2/app/data/local/backup_service.dart';
import 'package:calendario2/app/data/local/my_shared_pref.dart';
import 'package:calendario2/app/modules/home/providers/calendar_providers.dart';
import 'package:calendario2/app/data/model/language.dart';
import 'package:calendario2/config/theme/theme_provider.dart';
import 'package:calendario2/config/translations/localization_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AjustesState {
  final List<Language> languages;
  final Language selectedLanguage;

  const AjustesState({
    required this.languages,
    required this.selectedLanguage,
  });

  AjustesState copyWith({
    List<Language>? languages,
    Language? selectedLanguage,
  }) {
    return AjustesState(
      languages: languages ?? this.languages,
      selectedLanguage: selectedLanguage ?? this.selectedLanguage,
    );
  }
}

class AjustesNotifier extends Notifier<AjustesState> {
  @override
  AjustesState build() {
    final languages = _getSupportedLanguages();
    final languageCode = MySharedPref.getCurrentLocal().languageCode;
    final selectedLanguage = languages.firstWhere(
      (language) => language.languageCode == languageCode,
      orElse: () => languages.first,
    );

    return AjustesState(
      languages: List.unmodifiable(languages),
      selectedLanguage: selectedLanguage,
    );
  }

  List<Language> _getSupportedLanguages() => [
        Language(name: 'Español', languageCode: 'es'),
        Language(name: 'العربية', languageCode: 'ar'),
        Language(name: 'English', languageCode: 'en'),
      ];

  Future<void> cambioModo() async {
    final currentMode = ref.read(themeModeProvider);
    await changeTheme(currentMode != ThemeMode.dark);
  }

  Future<void> changeTheme(bool isDark) async {
    final mode = isDark ? ThemeMode.dark : ThemeMode.light;
    if (ref.read(themeModeProvider) == mode) return;

    await ref.read(themeModeProvider.notifier).setMode(mode);

    if (isDark) {
      CustomSnackBar.showCustomSnackBar(
        title: 'Tema oscuro',
        message: 'Modo oscuro activado',
      );
    } else {
      CustomSnackBar.showCustomSnackBar(
        title: 'Tema claro',
        message: 'Modo brillante activado',
      );
    }
  }

  Future<void> onLanguageTilePressed(String languageCode) async {
    if (!LocalizationService.isLanguageSupported(languageCode)) return;

    await ref.read(localeProvider.notifier).changeLanguage(languageCode);

    final languages = _getSupportedLanguages();
    final selected = languages.firstWhere(
      (language) => language.languageCode == languageCode,
    );

    state = state.copyWith(
      languages: List.unmodifiable(languages),
      selectedLanguage: selected,
    );
  }

  /// Exporta una copia JSON completa compatible con Android y web.
  Future<void> backupCompleteJson(BuildContext context) async {
    try {
      final json = await AppBackupService.createBackupJson();
      final bytes = Uint8List.fromList(utf8.encode(json));
      final timestamp = DateTime.now()
          .toIso8601String()
          .replaceAll(':', '-')
          .split('.')
          .first;

      final result = await FilePicker.saveFile(
        dialogTitle: 'Guardar copia de seguridad',
        fileName: 'calendario2_backup_$timestamp.json',
        bytes: bytes,
        mimeType: 'application/json',
      );

      if (result == null) return;

      if (!context.mounted) return;
      CustomSnackBar.showCustomSnackBar(
        title: 'Copia exportada',
        message: 'La copia JSON se ha guardado correctamente.',
      );
    } catch (e) {
      if (!context.mounted) return;
      CustomSnackBar.showCustomErrorSnackBar(
        title: 'Error al crear la copia',
        message: 'No se pudo guardar la copia: $e',
        duration: const Duration(seconds: 6),
      );
    }
  }

  /// Selecciona y restaura una copia JSON completa de la aplicación.
  Future<bool> _confirmCompleteJsonRestore(
    BuildContext context,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Restaurar copia completa'),
        content: const Text(
          'Esta operación sustituirá los datos actuales del calendario, '
          'los tipos de turno, el tema y las notas por los incluidos '
          'en la copia seleccionada.\\n\\n'
          'Se recomienda conservar una copia reciente de los datos actuales. '
          '¿Quieres continuar?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Continuar'),
          ),
        ],
      ),
    );

    return confirmed == true;
  }

  Future<void> restoreCompleteJson(BuildContext context) async {
    final confirmed = await _confirmCompleteJsonRestore(context);
    if (!confirmed || !context.mounted) return;

    try {
      final file = await FilePicker.pickFile(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (file == null) return;

      final bytes = await file.readAsBytes();
      final json = utf8.decode(bytes);

      AppBackupService.decodeAndValidateBackup(json);
      await AppBackupService.restoreBackupJson(json);

      // Actualizar los estados de Riverpod con los datos restaurados.
      await ref.read(cuadranteMapProvider.notifier).reload();
      await ref.read(turnoTypesProvider.notifier).reload();
      ref.invalidate(cuadranteNamesProvider);
      await ref.read(notasProvider.notifier).reload();

      if (!context.mounted) return;

      CustomSnackBar.showCustomSnackBar(
        title: 'Copia restaurada',
        message: 'Los datos se han restaurado correctamente.',
      );
    } on FormatException catch (e) {
      if (!context.mounted) return;

      CustomSnackBar.showCustomErrorSnackBar(
        title: 'Copia no válida',
        message: e.message,
        duration: const Duration(seconds: 6),
      );
    } catch (e) {
      if (!context.mounted) return;

      CustomSnackBar.showCustomErrorSnackBar(
        title: 'Error al restaurar la copia',
        message: 'No se pudo restaurar la copia: $e',
        duration: const Duration(seconds: 6),
      );
    }
  }

}

final ajustesProvider = NotifierProvider<AjustesNotifier, AjustesState>(
  AjustesNotifier.new,
);
