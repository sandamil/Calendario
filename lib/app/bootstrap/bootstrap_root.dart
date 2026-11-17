import 'dart:async';

import 'package:flutter/material.dart';

/// Describes a failure that happened while preparing the normal app tree.
class BootstrapFailure {
  const BootstrapFailure({
    required this.phase,
    required this.error,
    required this.stackTrace,
    required this.referenceId,
  });

  final String phase;
  final Object error;
  final StackTrace stackTrace;
  final String referenceId;
}

/// Mounts a lightweight shell before running asynchronous application setup.
///
/// The application tree is created only after [initialize] succeeds. A failed
/// initialization is rendered through [recoveryBuilder], which can later be
/// replaced with the full recovery flow without coupling this root to providers
/// or persistence repositories.
class BootstrapRoot extends StatefulWidget {
  const BootstrapRoot({
    required this.initialize,
    required this.applicationBuilder,
    required this.recoveryBuilder,
    super.key,
  });

  final Future<void> Function() initialize;
  final Widget Function() applicationBuilder;
  final Widget Function(BootstrapFailure failure, Future<void> Function() retry)
  recoveryBuilder;

  @override
  State<BootstrapRoot> createState() => _BootstrapRootState();
}

enum _BootstrapState { loading, ready, failed }

class _BootstrapRootState extends State<BootstrapRoot> {
  static int _failureSequence = 0;

  _BootstrapState _state = _BootstrapState.loading;
  BootstrapFailure? _failure;
  Future<void>? _initialization;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _startInitialization();
      }
    });
  }

  void _startInitialization() {
    if (_initialization != null) {
      return;
    }

    final initialization = _runInitialization();
    _initialization = initialization;
    unawaited(
      initialization.whenComplete(() {
        if (identical(_initialization, initialization)) {
          _initialization = null;
        }
      }),
    );
  }

  Future<void> _runInitialization() async {
    try {
      await Future<void>.sync(widget.initialize);
      if (!mounted) {
        return;
      }
      setState(() {
        _state = _BootstrapState.ready;
        _failure = null;
      });
    } catch (error, stackTrace) {
      if (!mounted) {
        return;
      }
      final failure = error is BootstrapFailure
          ? error
          : BootstrapFailure(
              phase: 'startup',
              error: error,
              stackTrace: stackTrace,
              referenceId: _newReferenceId(),
            );
      setState(() {
        _state = _BootstrapState.failed;
        _failure = failure;
      });
    }
  }

  Future<void> _retry() {
    final current = _initialization;
    if (current != null) {
      return current;
    }
    setState(() {
      _state = _BootstrapState.loading;
      _failure = null;
    });
    _startInitialization();
    return _initialization!;
  }

  String _newReferenceId() {
    _failureSequence++;
    final timestamp = DateTime.now().microsecondsSinceEpoch.toRadixString(16);
    return 'boot-$timestamp-${_failureSequence.toRadixString(16)}';
  }

  @override
  Widget build(BuildContext context) {
    switch (_state) {
      case _BootstrapState.loading:
        return const MaterialApp(
          debugShowCheckedModeBanner: false,
          home: _BootstrapLoadingScreen(),
        );
      case _BootstrapState.ready:
        return widget.applicationBuilder();
      case _BootstrapState.failed:
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          home: widget.recoveryBuilder(_failure!, _retry),
        );
    }
  }
}

class _BootstrapLoadingScreen extends StatelessWidget {
  const _BootstrapLoadingScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Iniciando Calendario'),
            ],
          ),
        ),
      ),
    );
  }
}
