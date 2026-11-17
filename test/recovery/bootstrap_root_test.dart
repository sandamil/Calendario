import 'dart:async';

import 'package:calendario2/app/bootstrap/bootstrap_root.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('mounts_loading_shell_before_startup_future_completes', (
    tester,
  ) async {
    final startup = Completer<void>();
    var applicationBuilt = false;
    var startupCalls = 0;
    var loadingShellMountedAtStartup = false;

    await tester.pumpWidget(
      BootstrapRoot(
        initialize: () {
          startupCalls++;
          loadingShellMountedAtStartup = find
              .text('Iniciando Calendario')
              .evaluate()
              .isNotEmpty;
          return startup.future;
        },
        applicationBuilder: () {
          applicationBuilt = true;
          return const MaterialApp(
            home: Scaffold(body: Text('Aplicación lista')),
          );
        },
        recoveryBuilder: (_, __) => const Text('Recuperación'),
      ),
    );

    expect(find.text('Iniciando Calendario'), findsOneWidget);
    expect(applicationBuilt, isFalse);
    expect(startupCalls, 1);
    expect(loadingShellMountedAtStartup, isTrue);

    startup.complete();
    await tester.pumpAndSettle();

    expect(find.text('Aplicación lista'), findsOneWidget);
    expect(applicationBuilt, isTrue);
  });

  testWidgets('shows_recovery_builder_when_startup_throws', (tester) async {
    final expectedFailure = BootstrapFailure(
      phase: 'startup',
      error: StateError('No se pudo inicializar'),
      stackTrace: StackTrace.current,
      referenceId: 'test-reference',
    );
    BootstrapFailure? displayedFailure;

    await tester.pumpWidget(
      BootstrapRoot(
        initialize: () async => throw expectedFailure,
        applicationBuilder: () =>
            const MaterialApp(home: Scaffold(body: Text('Aplicación lista'))),
        recoveryBuilder: (failure, _) {
          displayedFailure = failure;
          return Text('Fallo ${failure.referenceId}');
        },
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Fallo test-reference'), findsOneWidget);
    expect(displayedFailure, same(expectedFailure));
  });

  testWidgets('does_not_build_provider_app_on_failure', (tester) async {
    var applicationBuildCount = 0;

    await tester.pumpWidget(
      BootstrapRoot(
        initialize: () async => throw StateError('Fallo de arranque'),
        applicationBuilder: () {
          applicationBuildCount++;
          return const MaterialApp(home: Scaffold(body: Text('Árbol normal')));
        },
        recoveryBuilder: (_, __) => const Text('Interfaz de error'),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Interfaz de error'), findsOneWidget);
    expect(find.text('Árbol normal'), findsNothing);
    expect(applicationBuildCount, 0);
  });

  testWidgets('retry_runs_initialization_again', (tester) async {
    var attempts = 0;
    var applicationBuilt = false;

    await tester.pumpWidget(
      BootstrapRoot(
        initialize: () async {
          attempts++;
          if (attempts == 1) {
            throw StateError('Primer intento fallido');
          }
        },
        applicationBuilder: () {
          applicationBuilt = true;
          return const MaterialApp(
            home: Scaffold(body: Text('Aplicación lista')),
          );
        },
        recoveryBuilder: (_, retry) => Scaffold(
          body: ElevatedButton(
            onPressed: retry,
            child: const Text('Reintentar'),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(attempts, 1);
    expect(applicationBuilt, isFalse);
    await tester.tap(find.text('Reintentar'));
    await tester.pumpAndSettle();

    expect(attempts, 2);
    expect(find.text('Aplicación lista'), findsOneWidget);
    expect(applicationBuilt, isTrue);
  });
}
