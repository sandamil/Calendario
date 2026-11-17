import 'package:flutter/material.dart';

import '../../bootstrap/bootstrap_root.dart';
import '../../data/local/recovery_service.dart';
import 'recovery_controller.dart';

class RecoveryScreen extends StatefulWidget {
  const RecoveryScreen({
    super.key,
    required this.controller,
    required this.failure,
    required this.diagnose,
    required this.onRetry,
  });

  final RecoveryController controller;
  final BootstrapFailure failure;
  final Future<RecoveryDiagnostics> Function() diagnose;
  final Future<void> Function()? onRetry;

  @override
  State<RecoveryScreen> createState() => _RecoveryScreenState();
}

class _RecoveryScreenState extends State<RecoveryScreen> {
  late Future<RecoveryDiagnostics> _diagnostics;
  bool _preserveExisting = true;

  @override
  void initState() {
    super.initState();
    _diagnostics = widget.diagnose();
  }

  Future<void> _refreshDiagnostics() async {
    setState(() => _diagnostics = widget.diagnose());
  }

  Future<void> _restore() async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Confirmar restauración'),
        content: const Text(
          'Se sustituirán el calendario y las notas por los datos del backup. '
          'La operación se validará antes de volver al arranque normal.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
    if (!mounted) return;
    await widget.controller.restoreAfterConfirmation(
      confirmed: confirmed == true,
      preserveExisting: _preserveExisting,
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Recuperación de Calendario')),
    body: SafeArea(
      child: AnimatedBuilder(
        animation: widget.controller,
        builder: (context, _) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              'El arranque normal está detenido para proteger tus datos.',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            Text('Referencia técnica: ${widget.failure.referenceId}'),
            ExpansionTile(
              title: const Text('Detalles técnicos'),
              subtitle: Text('Fase: ${widget.failure.phase}'),
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: SelectableText(widget.failure.error.toString()),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Estado de almacenamiento',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                IconButton(
                  tooltip: 'Volver a diagnosticar',
                  onPressed: _refreshDiagnostics,
                  icon: const Icon(Icons.refresh),
                ),
              ],
            ),
            FutureBuilder<RecoveryDiagnostics>(
              future: _diagnostics,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const LinearProgressIndicator();
                }
                if (snapshot.hasError) {
                  return Text(
                    'No se pudo completar el diagnóstico: ${snapshot.error}',
                  );
                }
                final diagnostics = snapshot.data;
                if (diagnostics == null) return const SizedBox.shrink();
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _databaseStatus('Calendario', diagnostics.calendar),
                    _databaseStatus('Notas', diagnostics.notes),
                    Text(
                      'Diario SQLite anterior: ${diagnostics.legacyJournalStatus}',
                    ),
                    Text(
                      'Manifiesto de recuperación: ${diagnostics.externalManifestStatus}',
                    ),
                    if (diagnostics.detail != null)
                      Text('Detalle: ${diagnostics.detail}'),
                  ],
                );
              },
            ),
            const Divider(height: 32),
            FilledButton.icon(
              onPressed: widget.controller.isBusy
                  ? null
                  : widget.controller.pickBackup,
              icon: const Icon(Icons.folder_open),
              label: const Text('Seleccionar backup'),
            ),
            if (widget.controller.selectedBackupBytes != null)
              OutlinedButton.icon(
                onPressed: widget.controller.isBusy
                    ? null
                    : widget.controller.exportSelectedBackup,
                icon: const Icon(Icons.save_alt),
                label: const Text('Exportar backup seleccionado'),
              ),
            if (widget.controller.preview case final preview?) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Backup del ${preview.createdAt.toLocal()}'),
                      Text('Cuadrantes: ${preview.cuadranteCount}'),
                      Text('Turnos: ${preview.turnosCount}'),
                      Text('Temas: ${preview.themeCount}'),
                      Text('Notas: ${preview.notesCount}'),
                    ],
                  ),
                ),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: _preserveExisting,
                onChanged: widget.controller.isBusy
                    ? null
                    : (value) => setState(() => _preserveExisting = value),
                title: const Text(
                  'Conservar las bases actuales antes de restaurar',
                ),
              ),
              FilledButton.tonal(
                onPressed: widget.controller.isBusy ? null : _restore,
                child: const Text('Restaurar backup'),
              ),
            ],
            OutlinedButton(
              onPressed: widget.controller.isBusy
                  ? null
                  : () async {
                      final report = await widget.controller.preserveCurrent();
                      if (report != null && mounted) setState(() {});
                    },
              child: const Text('Conservar bases actuales'),
            ),
            if (widget.controller.preservation case final report?) ...[
              _preservedCopy('calendario', report.calendar),
              _preservedCopy('notas', report.notes),
            ],
            if (widget.controller.isBusy) ...[
              const SizedBox(height: 12),
              const LinearProgressIndicator(),
              const Text('Operación en curso…'),
            ],
            if (widget.controller.status == RecoveryControllerStatus.restored)
              const ListTile(
                leading: Icon(Icons.verified, color: Colors.green),
                title: Text('Las dos bases se restauraron y verificaron.'),
              ),
            if (widget.controller.errorMessage case final message?)
              Text(
                message,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            if (widget.onRetry != null)
              FilledButton.icon(
                onPressed: widget.controller.isBusy ? null : widget.onRetry,
                icon: const Icon(Icons.restart_alt),
                label: const Text('Reintentar arranque'),
              ),
          ],
        ),
      ),
    ),
  );

  Widget _databaseStatus(String label, DatabaseInspection report) => ListTile(
    dense: true,
    contentPadding: EdgeInsets.zero,
    title: Text(label),
    subtitle: Text(
      'Bytes: ${report.bytesAvailable ? (report.bytesReadable ? 'disponibles y legibles' : 'disponibles, lectura fallida') : 'no disponibles'}; '
      'apertura: ${report.openSucceeded ? 'correcta' : 'fallida'}; integridad: ${report.integrityStatus}',
    ),
    trailing: report.detail == null
        ? null
        : Tooltip(
            message: report.detail!,
            child: const Icon(Icons.info_outline),
          ),
  );

  Widget _preservedCopy(String label, PreservedDatabaseCopy copy) {
    if (copy.error != null) {
      return Text('No se pudo conservar $label: ${copy.error}');
    }
    if (!copy.available || copy.path == null) {
      return Text('No había base de $label para conservar.');
    }
    return TextButton(
      onPressed: () => widget.controller.exportPreservedCopy(
        copy.path!,
        'calendario2_${label}_preservado.db',
      ),
      child: Text('Exportar $label preservado'),
    );
  }
}
