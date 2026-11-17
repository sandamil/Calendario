import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

import '../../bootstrap/bootstrap_root.dart';
import '../../data/local/calendarDatabase.dart';
import '../../data/local/recovery_manifest_store.dart';
import '../../data/local/recovery_service.dart';
import '../../data/local/taskDatabase.dart';
import 'recovery_controller.dart';
import 'recovery_file_picker.dart';
import 'recovery_screen.dart';

class RecoveryEntryScreen extends StatefulWidget {
  const RecoveryEntryScreen({
    required this.failure,
    required this.onRetry,
    super.key,
  });

  final BootstrapFailure failure;
  final Future<void> Function() onRetry;

  @override
  State<RecoveryEntryScreen> createState() => _RecoveryEntryScreenState();
}

class _RecoveryEntryScreenState extends State<RecoveryEntryScreen> {
  late final Future<_RecoverySession> _session;

  @override
  void initState() {
    super.initState();
    _session = _createSession();
  }

  @override
  void dispose() {
    _session.then<void>(
      (session) => session.controller.dispose(),
      onError: (Object _, StackTrace __) {},
    );
    super.dispose();
  }

  Future<_RecoverySession> _createSession() async {
    final manifestStore = await createRecoveryManifestStore();
    final factory = kIsWeb ? databaseFactoryFfiWeb : databaseFactory;
    final service = RecoveryService(
      databaseFactory: factory,
      pathResolver: () async => RecoveryDatabasePaths(
        calendarTargetPath: await CalendarioDB().databasePath(),
        notesTargetPath: await NotasDB().databasePath(),
      ),
      manifestStore: manifestStore,
    );
    Future<void> closeDatabaseHandles() async {
      await CalendarioDB().closeDb();
      await NotasDB().close();
      await service.closeInspectionDatabases();
    }

    Future<void> retryAfterClosing() async {
      await closeDatabaseHandles();
      await widget.onRetry();
    }

    final controller = RecoveryController(
      picker: const PlatformRecoveryBackupPicker(),
      previewBackup: service.previewBackup,
      restoreBackup: (bytes, {required preserveExisting}) async {
        await closeDatabaseHandles();
        return service.restoreBackup(bytes, preserveExisting: preserveExisting);
      },
      preserveCurrentDatabases: service.preserveCurrentDatabasesForNewOperation,
      readPreservedBytes: service.readPreservedDatabaseBytes,
      retryBootstrap: retryAfterClosing,
    );
    return _RecoverySession(
      service: service,
      controller: controller,
      retry: retryAfterClosing,
    );
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<_RecoverySession>(
    future: _session,
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Scaffold(
          body: SafeArea(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Preparando herramientas de recuperación'),
                ],
              ),
            ),
          ),
        );
      }
      if (snapshot.hasError) {
        return Scaffold(
          appBar: AppBar(title: const Text('Recuperación no disponible')),
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                const Text(
                  'No se pudo preparar el almacenamiento de recuperación. '
                  'No se han sustituido las bases de datos.',
                ),
                const SizedBox(height: 12),
                SelectableText(snapshot.error.toString()),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: widget.onRetry,
                  icon: const Icon(Icons.restart_alt),
                  label: const Text('Reintentar arranque'),
                ),
              ],
            ),
          ),
        );
      }
      final session = snapshot.requireData;
      return RecoveryScreen(
        controller: session.controller,
        failure: widget.failure,
        diagnose: session.service.inspect,
        onRetry: session.retry,
      );
    },
  );
}

class _RecoverySession {
  const _RecoverySession({
    required this.service,
    required this.controller,
    required this.retry,
  });

  final RecoveryService service;
  final RecoveryController controller;
  final Future<void> Function() retry;
}
