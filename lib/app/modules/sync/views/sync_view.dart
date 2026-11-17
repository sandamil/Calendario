import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../config/supabase_config.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../data/local/calendarDatabase.dart';
import '../services/supabase_sync_service.dart';
import '../services/sync_merge_engine.dart';

class SyncView extends StatefulWidget {
  const SyncView({super.key});
  @override
  State<SyncView> createState() => _SyncViewState();
}

class _SyncViewState extends State<SyncView> {
  SupabaseSyncService? _service;
  StreamSubscription<User?>? _authSubscription;
  Future<SharedCalendarInfo?>? _groupFuture;
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _inviteCode = TextEditingController();
  List<String> _calendarNames = [];
  String? _selectedCalendar;
  String? _inviteCodeToShare;
  String? _message;
  bool _registerMode = false;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    if (supabaseInitialized) {
      _service = SupabaseSyncService.instance;
      _authSubscription = _service!.authStateChanges.listen((user) {
        if (!mounted) return;
        setState(() {
          _groupFuture = user == null
              ? Future.value(null)
              : _service!.currentGroup();
          if (user != null) {
            unawaited(_service!.startIfLinked());
          }
          _message = null;
          _inviteCodeToShare = null;
        });
      });
    }
    _loadCalendarNames();
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    _email.dispose();
    _password.dispose();
    _inviteCode.dispose();
    super.dispose();
  }

  Future<void> _loadCalendarNames() async {
    try {
      final rows = await CalendarioDB.db.getCuadranteList();
      final names =
          rows
              .map((row) => row.cuadranteName?.trim() ?? '')
              .where((name) => name.isNotEmpty)
              .toSet()
              .toList()
            ..sort();
      if (mounted)
        setState(() {
          _calendarNames = names;
          _selectedCalendar ??= names.isEmpty ? null : names.first;
        });
    } catch (error) {
      if (mounted)
        setState(
          () => _message =
              'No se pudieron leer los cuadrantes: ' + error.toString(),
        );
    }
  }

  Future<void> _authenticate() async {
    if (_email.text.trim().isEmpty || _password.text.length < 6) {
      setState(
        () => _message =
            'Introduce un correo y una contraseña de al menos 6 caracteres.',
      );
      return;
    }
    await _run(() async {
      if (_registerMode) {
        final authenticated = await _service!.register(
          _email.text,
          _password.text,
        );
        _message = authenticated
            ? 'Cuenta creada. Ya puedes vincular un calendario.'
            : 'Cuenta creada. Revisa tu correo y confirma la dirección antes de iniciar sesión.';
      } else {
        await _service!.signIn(_email.text, _password.text);
        _message = 'Sesión iniciada.';
      }
    });
  }

  Future<void> _resetPassword() async {
    await _run(() async {
      await _service!.sendPasswordReset(_email.text);
      _message = 'Si el correo está registrado, recibirás un enlace para restablecer la contraseña.';
    });
  }

  Future<void> _createGroup() async {
    final name = _selectedCalendar;
    if (name == null) {
      setState(() => _message = 'No hay cuadrantes guardados para compartir.');
      return;
    }
    await _run(() async {
      final info = await _service!.createSharedCalendar(name);
      _inviteCodeToShare = info.inviteCode;
      _groupFuture = _service!.currentGroup();
      final result = await _service!.sync();
      _message =
          'Calendario compartido creado. Operaciones enviadas: ' +
          result.updatedInCloud.toString();
    });
  }

  Future<void> _joinGroup() async {
    await _run(() async {
      final info = await _service!.joinSharedCalendar(_inviteCode.text);
      _groupFuture = _service!.currentGroup();
      final result = await _service!.sync();
      _message = result.conflicts.isEmpty
          ? 'Vinculado a "' +
                info.calendarName +
                '". Sincronización completada.'
          : 'Vinculado. Hay ' +
                result.conflicts.length.toString() +
                ' conflictos que necesitan decisión.';
    });
  }

  Future<void> _runSync() async {
    await _run(() async {
      var result = await _service!.sync(forcePull: true);
      if (result.conflicts.isNotEmpty && mounted) {
        final resolution = await showDialog<SyncConflictResolution>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: const Text('Cambios simultáneos'),
            content: Text(
              'Hay ' + result.conflicts.length.toString() + ' elementos modificados en este móvil y también en el calendario compartido. No se ha sobrescrito ninguno. ¿Qué copia quieres conservar?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(
                  dialogContext,
                  SyncConflictResolution.keepThisDevice,
                ),
                child: const Text('Conservar este móvil'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(
                  dialogContext,
                  SyncConflictResolution.useSharedCopy,
                ),
                child: const Text('Usar el compartido'),
              ),
            ],
          ),
        );
        if (resolution == null) {
          _message =
              'Sincronización parcial. Los conflictos siguen pendientes.';
          return;
        }
        result = await _service!.sync(forcePull: true, resolution: resolution);
      }
      _message = result.conflicts.isEmpty
          ? 'Sincronización terminada. Cambios locales: ' +
                result.updatedOnDevice.toString() +
                '; operaciones en nube: ' +
                result.updatedInCloud.toString() +
                '.'
          : 'Quedan ' +
                result.conflicts.length.toString() +
                ' conflictos sin resolver.';
      await _loadCalendarNames();
    });
  }

  Future<void> _regenerateInviteCode() async {
    await _run(() async {
      _inviteCodeToShare = await _service!.regenerateInviteCode();
      _message =
          'Se ha generado un código nuevo. El anterior deja de funcionar.';
    });
  }

  Future<void> _leaveGroup() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Desvincular calendario'),
        content: const Text(
          'Se eliminará la vinculación. Si eres el propietario, también se borrará el calendario compartido de la nube. Los datos locales de este móvil no se borrarán.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Continuar'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await _run(() async {
      await _service!.leaveGroup();
      _groupFuture = Future.value(null);
      _message = 'Calendario desvinculado. Los datos locales se conservan.';
    });
  }

  Future<void> _run(Future<void> Function() action) async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _message = null;
    });
    try {
      await action();
    } catch (error) {
      _message = _friendlyError(error);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  String _friendlyError(Object error) {
    if (error is AuthException) {
      final message = error.message.toLowerCase();
      if (message.contains('already registered') ||
          message.contains('already been registered')) {
        return 'Ese correo ya tiene una cuenta.';
      }
      if (message.contains('invalid login credentials')) {
        return 'Correo o contraseña incorrectos.';
      }
      if (message.contains('email not confirmed')) {
        return 'Confirma tu correo antes de iniciar sesión.';
      }
      if (message.contains('password')) {
        return 'Comprueba la contraseña; debe tener al menos 6 caracteres.';
      }
      return error.message;
    }
    if (error is PostgrestException) {
      return 'No se pudo completar la operación en la base de datos: ${error.message}';
    }
    return error.toString().replaceFirst('Exception: ', '');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Volver al menú',
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.go('/menu'),
        ),
        title: const Text('Sincronización'),
      ),
      body: !_supabaseReady
          ? _supabaseUnavailable()
          : StreamBuilder<User?>(
              stream: _service!.authStateChanges,
              builder: (context, snapshot) {
                final user = snapshot.data ?? _service!.currentUser;
                if (snapshot.connectionState == ConnectionState.waiting &&
                    user == null) {
                  return const Center(child: CircularProgressIndicator());
                }
                return user == null
                    ? _authenticationPanel(theme)
                    : _sharedPanel(theme, user);
              },
            ),
    );
  }

  bool get _supabaseReady => _service != null && supabaseInitialized;

  Widget _supabaseUnavailable() => const Center(
    child: Padding(
      padding: EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.cloud_off_rounded, size: 48),
          SizedBox(height: 12),
          Text(
            'Servicios en la nube no disponibles',
            style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            'La aplicación sigue funcionando en modo local. No se ha podido inicializar Supabase en este dispositivo.',
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ),
  );

  Widget _authenticationPanel(ThemeData theme) => ListView(
    padding: const EdgeInsets.all(20),
    children: [
      const Icon(Icons.cloud_sync_rounded, size: 48),
      const SizedBox(height: 12),
      Text(
        _registerMode ? 'Crear cuenta' : 'Iniciar sesión',
        textAlign: TextAlign.center,
        style: theme.textTheme.headlineSmall,
      ),
      const SizedBox(height: 8),
      const Text(
        'Usa la misma cuenta en tus dispositivos para gestionar tus calendarios compartidos.',
        textAlign: TextAlign.center,
      ),
      const SizedBox(height: 20),
      TextField(
        controller: _email,
        keyboardType: TextInputType.emailAddress,
        autofillHints: const [AutofillHints.email],
        decoration: const InputDecoration(
          labelText: 'Correo electrónico',
          prefixIcon: Icon(Icons.email_outlined),
          border: OutlineInputBorder(),
        ),
      ),
      const SizedBox(height: 12),
      TextField(
        controller: _password,
        obscureText: true,
        autofillHints: const [AutofillHints.password],
        decoration: const InputDecoration(
          labelText: 'Contraseña (mínimo 6 caracteres)',
          prefixIcon: Icon(Icons.lock_outline),
          border: OutlineInputBorder(),
        ),
      ),
      const SizedBox(height: 16),
      FilledButton.icon(
        onPressed: _busy ? null : _authenticate,
        icon: Icon(_registerMode ? Icons.person_add_alt_1 : Icons.login),
        label: Text(_registerMode ? 'Crear cuenta' : 'Entrar'),
      ),
      TextButton(
        onPressed: _busy
            ? null
            : () => setState(() {
                _registerMode = !_registerMode;
                _message = null;
              }),
        child: Text(
          _registerMode
              ? 'Ya tengo cuenta: iniciar sesión'
              : 'Crear una cuenta nueva',
        ),
      ),
      if (!_registerMode)
        TextButton(
          onPressed: _busy ? null : _resetPassword,
          child: const Text('He olvidado mi contraseña'),
        ),
      _messagePanel(theme),
      if (_busy)
        const Center(
          child: Padding(
            padding: EdgeInsets.all(12),
            child: CircularProgressIndicator(),
          ),
        ),
    ],
  );

  Widget _sharedPanel(
    ThemeData theme,
    User user,
  ) => FutureBuilder<SharedCalendarInfo?>(
    future: _groupFuture ??= _service!.currentGroup(),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting)
        return const Center(child: CircularProgressIndicator());
      final group = snapshot.data;
      return ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const CircleAvatar(child: Icon(Icons.person_outline)),
            title: Text(user.email ?? 'Cuenta conectada'),
            subtitle: const Text('Sesión autenticada con Supabase'),
            trailing: IconButton(
              tooltip: 'Cerrar sesión',
              onPressed: _busy ? null : () => _run(_service!.signOut),
              icon: const Icon(Icons.logout_rounded),
            ),
          ),
          const Divider(),
          if (group == null) ...[
            Text(
              'Crear calendario compartido',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 6),
            const Text(
              'Elige un cuadrante existente. Se compartirán sus turnos y también las notas de la aplicación. Las alarmas programadas seguirán siendo propias de cada dispositivo.',
            ),
            const SizedBox(height: 12),
            if (_calendarNames.isEmpty)
              const Text('Primero crea un cuadrante y asígnale algunos turnos.')
            else
              DropdownButtonFormField<String>(
                initialValue: _selectedCalendar,
                decoration: const InputDecoration(
                  labelText: 'Cuadrante',
                  border: OutlineInputBorder(),
                ),
                items: _calendarNames
                    .map(
                      (name) =>
                          DropdownMenuItem(value: name, child: Text(name)),
                    )
                    .toList(),
                onChanged: _busy
                    ? null
                    : (value) => setState(() => _selectedCalendar = value),
              ),
            const SizedBox(height: 10),
            FilledButton.icon(
              onPressed: _busy || _calendarNames.isEmpty ? null : _createGroup,
              icon: const Icon(Icons.add_link_rounded),
              label: const Text('Crear y compartir'),
            ),
            const SizedBox(height: 24),
            Text('Unirse con código', style: theme.textTheme.titleLarge),
            const SizedBox(height: 8),
            TextField(
              controller: _inviteCode,
              textCapitalization: TextCapitalization.characters,
              maxLength: 12,
              decoration: const InputDecoration(
                labelText: 'Código de invitación',
                border: OutlineInputBorder(),
              ),
            ),
            FilledButton.icon(
              onPressed: _busy ? null : _joinGroup,
              icon: const Icon(Icons.group_add_rounded),
              label: const Text('Unirme al calendario'),
            ),
          ] else ...[
            Text('Calendario compartido', style: theme.textTheme.titleLarge),
            const SizedBox(height: 8),
            Card(
              child: ListTile(
                leading: const Icon(Icons.calendar_month_rounded),
                title: Text(group.calendarName),
                subtitle: Text(
                  group.memberCount.toString() +
                      ' miembro(s) · ' +
                      (group.isOwner ? 'Propietario' : 'Miembro'),
                ),
              ),
            ),
            FilledButton.icon(
              onPressed: _busy ? null : _runSync,
              icon: const Icon(Icons.sync_rounded),
              label: const Text('Sincronizar ahora'),
            ),
            if (group.isOwner)
              TextButton.icon(
                onPressed: _busy ? null : _regenerateInviteCode,
                icon: const Icon(Icons.key_rounded),
                label: const Text('Generar código de invitación'),
              ),
            OutlinedButton.icon(
              onPressed: _busy ? null : _leaveGroup,
              icon: const Icon(Icons.link_off_rounded),
              label: Text(
                group.isOwner ? 'Eliminar grupo compartido' : 'Salir del grupo',
              ),
            ),
            if (_inviteCodeToShare != null) ...[
              const SizedBox(height: 14),
              const Text('Código para invitar a otra persona'),
              SelectableText(
                _inviteCodeToShare!,
                style: theme.textTheme.headlineSmall,
              ),
              TextButton.icon(
                onPressed: () async {
                  await Clipboard.setData(
                    ClipboardData(text: _inviteCodeToShare!),
                  );
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Código copiado')),
                  );
                },
                icon: const Icon(Icons.copy_rounded),
                label: const Text('Copiar código'),
              ),
            ],
          ],
          _messagePanel(theme),
          if (_busy)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(),
              ),
            ),
          const SizedBox(height: 12),
          const Text(
            'Los turnos y las notas se guardan primero en este dispositivo. Solo se envían los registros modificados; los cambios recibidos se aplican automáticamente mientras la conexión esté activa.',
            style: TextStyle(fontSize: 12),
          ),
        ],
      );
    },
  );

  Widget _messagePanel(ThemeData theme) {
    if (_message == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Text(
        _message!,
        style: TextStyle(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
