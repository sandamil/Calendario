import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../data/local/calendarDatabase.dart';
import '../../../data/local/taskDatabase.dart';
import '../../notas/services/notificaciones_service.dart';
import 'sync_events.dart';
import 'sync_merge_engine.dart';

class SharedCalendarInfo {
  const SharedCalendarInfo({
    required this.id,
    required this.calendarName,
    required this.ownerUid,
    required this.memberCount,
    required this.isOwner,
    this.inviteCode,
  });

  final String id;
  final String calendarName;
  final String ownerUid;
  final int memberCount;
  final bool isOwner;
  final String? inviteCode;
}

class SharedCalendarSyncResult {
  const SharedCalendarSyncResult({
    required this.updatedOnDevice,
    required this.updatedInCloud,
    required this.conflicts,
    required this.pendingChanges,
  });

  final int updatedOnDevice;
  final int updatedInCloud;
  final List<String> conflicts;
  final int pendingChanges;
}

class SupabaseSyncService {
  SupabaseSyncService._();

  static final SupabaseSyncService instance = SupabaseSyncService._();

  static const _savedCalendarIdKey = 'supabase_shared_calendar_id';
  static const _savedCalendarNameKey = 'supabase_shared_calendar_name';
  static const _savedOwnerIdKey = 'supabase_shared_calendar_owner';
  static const _savedRoleKey = 'supabase_shared_calendar_role';
  static const _savedMemberCountKey = 'supabase_shared_calendar_members';
  static const _cursorPrefix = 'supabase_sync_cursor_v1_';
  static const _codeAlphabet = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';

  SupabaseClient get _client => Supabase.instance.client;
  User? get currentUser => _client.auth.currentUser;
  Stream<User?> get authStateChanges =>
      _client.auth.onAuthStateChange.map((state) => state.session?.user);

  RealtimeChannel? _channel;
  String? _activeCalendarId;
  bool _pulling = false;
  StreamSubscription<void>? _localChangesSubscription;
  Timer? _localSyncDebounce;
  Future<SharedCalendarSyncResult>? _activeSync;

  Future<bool> register(String email, String password) async {
    final response = await _client.auth.signUp(
      email: email.trim(),
      password: password,
    );
    return response.session != null;
  }

  Future<void> signIn(String email, String password) async {
    await _client.auth.signInWithPassword(
      email: email.trim(),
      password: password,
    );
  }

  Future<void> sendPasswordReset(String email) async {
    final value = email.trim();
    if (value.isEmpty) {
      throw ArgumentError('Introduce el correo de tu cuenta.');
    }
    await _client.auth.resetPasswordForEmail(value);
  }

  Future<void> signOut() async {
    await _stopRealtime();
    await _stopLocalChangeListener();
    await _client.auth.signOut();
  }

  Future<SharedCalendarInfo> createSharedCalendar(String calendarName) async {
    final user = _requireUser();
    if (await currentGroup() != null) {
      throw StateError(
        'Ya tienes un calendario compartido vinculado. Desvincúlalo antes de crear otro.',
      );
    }
    final name = calendarName.trim();
    if (name.isEmpty) {
      throw ArgumentError('Selecciona un cuadrante para compartir.');
    }

    final code = _newInviteCode();
    final codeHash = _hash(code);
    final id = await _client.rpc(
      'create_shared_calendar',
      params: {'p_calendar_name': name, 'p_invite_code_hash': codeHash},
    ) as String;

    await _saveGroup(
      id,
      name,
      ownerUid: user.id,
      isOwner: true,
      memberCount: 1,
    );
    await CalendarioDB.db.queueAllForSync(calendarName: name);
    await NotasDB.instance.queueAllForSync();
    await _startRealtime(id, calendarName: name);
    _ensureLocalChangeListener();
    return SharedCalendarInfo(
      id: id,
      calendarName: name,
      ownerUid: user.id,
      memberCount: 1,
      isOwner: true,
      inviteCode: code,
    );
  }

  Future<SharedCalendarInfo> joinSharedCalendar(String rawCode) async {
    _requireUser();
    if (await currentGroup() != null) {
      throw StateError(
        'Ya tienes un calendario compartido vinculado. Desvincúlalo antes de unirte a otro.',
      );
    }
    final code = rawCode.trim().toUpperCase().replaceAll(
      RegExp(r'[^A-Z0-9]'),
      '',
    );
    if (code.length != 12) {
      throw const FormatException('El código debe tener 12 caracteres.');
    }

    final id = await _client.rpc(
      'join_shared_calendar',
      params: {'p_invite_code_hash': _hash(code)},
    ) as String;
    final group = await _loadGroup(id);
    await _saveGroup(
      id,
      group.calendarName,
      ownerUid: group.ownerUid,
      isOwner: group.isOwner,
      memberCount: group.memberCount,
    );
    await CalendarioDB.db.queueAllForSync(calendarName: group.calendarName);
    await NotasDB.instance.queueAllForSync();
    await _startRealtime(id, calendarName: group.calendarName);
    _ensureLocalChangeListener();
    return group.copyWith(inviteCode: null);
  }

  Future<SharedCalendarInfo?> currentGroup() async {
    final user = currentUser;
    if (user == null) return null;
    final prefs = await SharedPreferences.getInstance();
    var id = prefs.getString(_savedCalendarIdKey);
    if (id == null || id.isEmpty) {
      final membership = await _client
          .from('shared_calendar_members')
          .select('calendar_id')
          .eq('user_id', user.id)
          .maybeSingle();
      id = membership?['calendar_id']?.toString();
      if (id == null || id.isEmpty) return null;
    }
    try {
      final group = await _loadGroup(id);
      await _saveGroup(
        group.id,
        group.calendarName,
        ownerUid: group.ownerUid,
        isOwner: group.isOwner,
        memberCount: group.memberCount,
      );
      return group;
    } on StateError {
      await prefs.remove(_savedCalendarIdKey);
      await prefs.remove(_savedCalendarNameKey);
      await prefs.remove(_savedOwnerIdKey);
      await prefs.remove(_savedRoleKey);
      await prefs.remove(_savedMemberCountKey);
      await _stopRealtime();
      return null;
    } on PostgrestException catch (error) {
      if (error.code == 'PGRST116' || error.code == '42501') {
        await prefs.remove(_savedCalendarIdKey);
        await prefs.remove(_savedCalendarNameKey);
        await prefs.remove(_savedOwnerIdKey);
        await prefs.remove(_savedRoleKey);
        await prefs.remove(_savedMemberCountKey);
        await _stopRealtime();
        return null;
      }
      rethrow;
    }
  }

  Future<SharedCalendarInfo> _loadGroup(String id) async {
    final user = _requireUser();
    final membership = await _client
        .from('shared_calendar_members')
        .select('role')
        .eq('calendar_id', id)
        .eq('user_id', user.id)
        .maybeSingle();
    if (membership == null) {
      throw StateError('Tu cuenta ya no pertenece a este calendario.');
    }
    final calendar = await _client
        .from('shared_calendars')
        .select('id, owner_id, calendar_name')
        .eq('id', id)
        .single();
    final members = await _client
        .from('shared_calendar_members')
        .select('user_id')
        .eq('calendar_id', id);
    return SharedCalendarInfo(
      id: id,
      calendarName: calendar['calendar_name'] as String,
      ownerUid: calendar['owner_id'] as String,
      memberCount: (members as List).length,
      isOwner: membership['role'] == 'owner',
    );
  }

  Future<String> regenerateInviteCode() async {
    final group = await currentGroup();
    if (group == null || !group.isOwner) {
      throw StateError('Solo el propietario puede generar un nuevo código.');
    }
    final code = _newInviteCode();
    await _client.rpc(
      'rotate_shared_calendar_invite',
      params: {'p_calendar_id': group.id, 'p_invite_code_hash': _hash(code)},
    );
    return code;
  }

  Future<void> leaveGroup() async {
    final group = await currentGroup();
    if (group == null) return;
    await _client.rpc(
      'leave_shared_calendar',
      params: {'p_calendar_id': group.id},
    );
    await _stopRealtime();
    await _stopLocalChangeListener();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_savedCalendarIdKey);
    await prefs.remove(_savedCalendarNameKey);
    await prefs.remove(_savedOwnerIdKey);
    await prefs.remove(_savedRoleKey);
    await prefs.remove(_savedMemberCountKey);
  }

  Future<SharedCalendarSyncResult> sync({
    bool forcePull = false,
    SyncConflictResolution resolution = SyncConflictResolution.none,
  }) async {
    final active = _activeSync;
    if (active != null) return active;
    final operation = _performSync(
      forcePull: forcePull,
      resolution: resolution,
    );
    _activeSync = operation;
    try {
      return await operation;
    } finally {
      _activeSync = null;
    }
  }

  Future<SharedCalendarSyncResult> _performSync({
    bool forcePull = false,
    SyncConflictResolution resolution = SyncConflictResolution.none,
  }) async {
    _requireUser();
    final group = await _cachedGroup();
    if (group == null) {
      throw StateError('No hay un calendario compartido vinculado.');
    }
    await _startRealtime(group.id, calendarName: group.calendarName);

    var cloudWrites = 0;
    var deviceUpdates = 0;
    final conflicts = <String>[];
    final shiftChanges = await CalendarioDB.db.pendingSyncChanges();
    final noteChanges = await NotasDB.instance.pendingSyncChanges();
    final acknowledgedShifts = <Map<String, Object?>>[];
    final acknowledgedNotes = <Map<String, Object?>>[];

    for (final change in shiftChanges) {
      final key = change['sync_key']?.toString();
      if (key == null) continue;
      final local = await CalendarioDB.db.shiftBySyncKey(key);
      if (local != null &&
          local['cuadranteName']?.toString() != group.calendarName) {
        continue;
      }
      final isDelete = change['operation'] == 'delete' || local == null;
      final expectedRevision = (local?['syncRevision'] as num?)?.toInt() ?? 0;
      final params = <String, dynamic>{
        'p_calendar_id': group.id,
        'p_sync_key': key,
        'p_expected_revision': expectedRevision,
      };
      if (!isDelete) {
        params.addAll({
          'p_shift_date': local['datetime'],
          'p_title': local['title'],
          'p_description': local['description'],
          'p_start_hour': local['startHour'],
          'p_end_hour': local['endHour'],
          'p_color': local['color'],
        });
      }

      try {
        final rawRevision = await _client.rpc(
          isDelete
              ? 'tombstone_shared_calendar_shift'
              : 'save_shared_calendar_shift',
          params: params,
        );
        final revision = (rawRevision as num?)?.toInt();
        if (!isDelete && revision != null) {
          await CalendarioDB.db.setSyncRevision(key, revision);
        }
        if (revision != null) cloudWrites++;
        acknowledgedShifts.add(change);
      } on PostgrestException catch (error) {
        if (error.code != '40001') rethrow;
        final remote = await _client
            .from('shared_calendar_shifts')
            .select()
            .eq('calendar_id', group.id)
            .eq('sync_key', key)
            .maybeSingle();
        if (isDelete && remote?['is_deleted'] == true) {
          acknowledgedShifts.add(change);
          continue;
        }
        if (remote != null &&
            local != null &&
            _sameShiftFields(local, remote)) {
          await CalendarioDB.db.applyRemoteShift(
            remote,
            calendarName: group.calendarName,
          );
          acknowledgedShifts.add(change);
          deviceUpdates++;
          continue;
        }
        if (resolution == SyncConflictResolution.none) {
          conflicts.add('Turno: $key');
          continue;
        }
        if (resolution == SyncConflictResolution.useSharedCopy) {
          if (remote == null) {
            conflicts.add('Turno: $key');
            continue;
          }
          await CalendarioDB.db.applyRemoteShift(
            remote,
            calendarName: group.calendarName,
          );
          acknowledgedShifts.add(change);
          deviceUpdates++;
          continue;
        }
        final remoteRevision = (remote?['revision'] as num?)?.toInt() ?? 0;
        params['p_expected_revision'] = remoteRevision;
        final rawRevision = await _client.rpc(
          isDelete
              ? 'tombstone_shared_calendar_shift'
              : 'save_shared_calendar_shift',
          params: params,
        );
        final revision = (rawRevision as num?)?.toInt();
        if (!isDelete && revision != null) {
          await CalendarioDB.db.setSyncRevision(key, revision);
        }
        if (revision != null) cloudWrites++;
        acknowledgedShifts.add(change);
      }
    }

    for (final change in noteChanges) {
      final key = change['sync_key']?.toString();
      if (key == null) continue;
      final local = await NotasDB.instance.noteBySyncKey(key);
      final isDelete = change['operation'] == 'delete' || local == null;
      final expectedRevision = (local?['syncRevision'] as num?)?.toInt() ?? 0;
      final params = <String, dynamic>{
        'p_calendar_id': group.id,
        'p_sync_key': key,
        'p_expected_revision': expectedRevision,
      };
      if (!isDelete) {
        final start = (local['startTimeMilliseconds'] as num?)?.toInt();
        final noteDate = start == null
            ? null
            : DateTime.fromMillisecondsSinceEpoch(start)
                  .toIso8601String()
                  .substring(0, 10);
        params.addAll({
          'p_note_date': noteDate,
          'p_title': local['title'],
          'p_content': local['notes'] ?? '',
          'p_site': local['site'],
          'p_start_time_ms': local['startTimeMilliseconds'],
          'p_end_time_ms': local['endTimeMilliseconds'],
          'p_is_important': local['isImportant'] == 1,
          'p_notification_mode': local['notificationMode'] == 'alarma'
              ? 'alarma'
              : 'notificacion',
        });
      }

      try {
        final rawRevision = await _client.rpc(
          isDelete
              ? 'tombstone_shared_calendar_note'
              : 'save_shared_calendar_note',
          params: params,
        );
        final revision = (rawRevision as num?)?.toInt();
        if (!isDelete && revision != null) {
          await NotasDB.instance.setSyncRevision(key, revision);
        }
        if (revision != null) cloudWrites++;
        acknowledgedNotes.add(change);
      } on PostgrestException catch (error) {
        if (error.code != '40001') rethrow;
        final remote = await _client
            .from('shared_calendar_notes')
            .select()
            .eq('calendar_id', group.id)
            .eq('sync_key', key)
            .maybeSingle();
        if (isDelete && remote?['is_deleted'] == true) {
          acknowledgedNotes.add(change);
          continue;
        }
        if (remote != null && local != null && _sameNoteFields(local, remote)) {
          await NotasDB.instance.applyRemoteNote(remote);
          acknowledgedNotes.add(change);
          deviceUpdates++;
          continue;
        }
        if (resolution == SyncConflictResolution.none) {
          conflicts.add('Nota: $key');
          continue;
        }
        if (resolution == SyncConflictResolution.useSharedCopy) {
          if (remote == null) {
            conflicts.add('Nota: $key');
            continue;
          }
          await NotasDB.instance.applyRemoteNote(remote);
          acknowledgedNotes.add(change);
          deviceUpdates++;
          continue;
        }
        final remoteRevision = (remote?['revision'] as num?)?.toInt() ?? 0;
        params['p_expected_revision'] = remoteRevision;
        final rawRevision = await _client.rpc(
          isDelete
              ? 'tombstone_shared_calendar_note'
              : 'save_shared_calendar_note',
          params: params,
        );
        final revision = (rawRevision as num?)?.toInt();
        if (!isDelete && revision != null) {
          await NotasDB.instance.setSyncRevision(key, revision);
        }
        if (revision != null) cloudWrites++;
        acknowledgedNotes.add(change);
      }
    }

    await CalendarioDB.db.acknowledgeSyncChanges(acknowledgedShifts);
    await NotasDB.instance.acknowledgeSyncChanges(acknowledgedNotes);

    final prefs = await SharedPreferences.getInstance();
    final cursorKey = '$_cursorPrefix' + group.id;
    final cursor = prefs.getString(cursorKey);
    final shouldPull = conflicts.isEmpty && (forcePull || cursor == null);
    if (shouldPull) {
      final pulled = await _pullChanges(
        group.id,
        group.calendarName,
        cursorKey,
        cursor,
      );
      deviceUpdates += pulled;
    }

    final remainingShifts = await CalendarioDB.db.pendingSyncChanges();
    final remainingNotes = await NotasDB.instance.pendingSyncChanges();
    return SharedCalendarSyncResult(
      updatedOnDevice: deviceUpdates,
      updatedInCloud: cloudWrites,
      conflicts: List.unmodifiable(conflicts),
      pendingChanges: remainingShifts.length + remainingNotes.length,
    );
  }

  Future<int> _pullChanges(
    String calendarId,
    String calendarName,
    String cursorKey,
    String? cursor,
  ) async {
    if (_pulling) return 0;
    _pulling = true;
    try {
      final serverTime = await _client.rpc('get_sync_server_time');
      final upperBound = DateTime.parse(serverTime.toString())
          .toUtc()
          .toIso8601String();

      var shiftQuery = _client
          .from('shared_calendar_shifts')
          .select()
          .eq('calendar_id', calendarId)
          .lte('updated_at', upperBound);
      var noteQuery = _client
          .from('shared_calendar_notes')
          .select()
          .eq('calendar_id', calendarId)
          .lte('updated_at', upperBound);
      if (cursor != null) {
        shiftQuery = shiftQuery.gt('updated_at', cursor);
        noteQuery = noteQuery.gt('updated_at', cursor);
      }
      final results = await Future.wait([shiftQuery, noteQuery]);
      final shifts = (results[0] as List).cast<Map<String, dynamic>>();
      final notes = (results[1] as List).cast<Map<String, dynamic>>();
      var updated = 0;
      for (final row in shifts) {
        final key = row['sync_key']?.toString();
        if (key != null && await CalendarioDB.db.hasPendingSyncChange(key)) {
          continue;
        }
        final applied = await CalendarioDB.db.applyRemoteShift(
          row,
          calendarName: calendarName,
        );
        if (applied) updated++;
      }
      for (final row in notes) {
        final key = row['sync_key']?.toString();
        if (key != null && await NotasDB.instance.hasPendingSyncChange(key)) {
          continue;
        }
        final applied = await _applyRemoteNoteLocally(row);
        if (applied) updated++;
      }

      final safeCursor = DateTime.parse(upperBound)
          .subtract(const Duration(seconds: 2))
          .toUtc()
          .toIso8601String();
      await (await SharedPreferences.getInstance()).setString(
        cursorKey,
        safeCursor,
      );
      if (updated > 0) SyncEvents.instance.notify();
      return updated;
    } finally {
      _pulling = false;
    }
  }

  Future<void> startIfLinked() async {
    if (currentUser == null) return;
    final group = await _cachedGroup() ?? await currentGroup();
    if (group != null) {
      _ensureLocalChangeListener();
      await _startRealtime(group.id, calendarName: group.calendarName);
    }
  }

  void _ensureLocalChangeListener() {
    if (_localChangesSubscription != null) return;
    _localChangesSubscription = SyncEvents.instance.localChanges.listen((_) {
      _localSyncDebounce?.cancel();
      _localSyncDebounce = Timer(const Duration(milliseconds: 650), () {
        unawaited(_uploadPendingLocalChanges());
      });
    });
  }

  Future<void> _uploadPendingLocalChanges() async {
    if (currentUser == null || await _cachedGroup() == null) return;
    try {
      await sync();
    } catch (error) {
      // The durable SQLite outbox is retained; reconnect or manual sync retries it.
      // ignore: avoid_print
      print(
        '[SUPABASE SYNC] Cambios pendientes conservados para reintento: $error',
      );
    }
  }

  Future<void> _stopLocalChangeListener() async {
    _localSyncDebounce?.cancel();
    _localSyncDebounce = null;
    await _localChangesSubscription?.cancel();
    _localChangesSubscription = null;
  }

  Future<void> _startRealtime(
    String calendarId, {
    required String calendarName,
  }) async {
    if (_activeCalendarId == calendarId && _channel != null) return;
    await _stopRealtime();
    _activeCalendarId = calendarId;
    final prefs = await SharedPreferences.getInstance();
    final cursorKey = '$_cursorPrefix${calendarId}';
    _channel = _client
        .channel('calendar-sync-$calendarId')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'shared_calendar_shifts',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'calendar_id',
            value: calendarId,
          ),
          callback: (payload) {
            final row = payload.newRecord;
            if (row.isNotEmpty) {
              unawaited(_handleRealtimeShift(row, calendarName));
            }
          },
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'shared_calendar_notes',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'calendar_id',
            value: calendarId,
          ),
          callback: (payload) {
            final row = payload.newRecord;
            if (row.isNotEmpty) {
              unawaited(_handleRealtimeNote(row));
            }
          },
        )
        .subscribe((status, [error]) {
          if (status == RealtimeSubscribeStatus.subscribed) {
            final cursor = prefs.getString(cursorKey);
            unawaited(() async {
              try {
                await _pullChanges(calendarId, calendarName, cursorKey, cursor);
                await sync();
              } catch (error) {
                // Local outbox is durable; next reconnect or manual sync retries.
                // ignore: avoid_print
                print('[SUPABASE SYNC] Reanudación pendiente: $error');
              }
            }());
          }
        });
  }

  Future<void> _handleRealtimeShift(
    Map<String, dynamic> row,
    String calendarName,
  ) async {
    final key = row['sync_key']?.toString();
    if (key == null || key.isEmpty) return;
    if (await CalendarioDB.db.hasPendingSyncChange(key)) {
      await _uploadPendingLocalChanges();
      return;
    }
    final applied = await CalendarioDB.db.applyRemoteShift(
      row,
      calendarName: calendarName,
    );
    if (!applied) {
      await _uploadPendingLocalChanges();
      return;
    }
    SyncEvents.instance.notify();
  }

  Future<void> _handleRealtimeNote(Map<String, dynamic> row) async {
    final key = row['sync_key']?.toString();
    if (key == null || key.isEmpty) return;
    if (await NotasDB.instance.hasPendingSyncChange(key)) {
      await _uploadPendingLocalChanges();
      return;
    }
    final applied = await _applyRemoteNoteLocally(row);
    if (!applied) {
      await _uploadPendingLocalChanges();
      return;
    }
    SyncEvents.instance.notify();
  }

  Future<bool> _applyRemoteNoteLocally(Map<String, dynamic> row) async {
    final key = row['sync_key']?.toString();
    if (key == null || key.isEmpty) return false;

    final previous = await NotasDB.instance.noteBySyncKey(key);
    final applied = await NotasDB.instance.applyRemoteNote(row);
    if (!applied || previous == null) return applied;

    final alarmId =
        (previous['idAlarma'] as num?)?.toInt() ??
        (previous['id'] as num?)?.toInt();
    if (alarmId == null) return true;

    try {
      if (row['is_deleted'] == true) {
        await NotificacionesService.instance.cancelar(alarmId);
      } else if (previous['isAlarmaCreated'] == 1) {
        final alarmTimestamp = (previous['alarmaTimestamp'] as num?)?.toInt();
        if (alarmTimestamp != null) {
          await NotificacionesService.instance.programar(
            id: alarmId,
            titulo: 'Nota: ${row['title'] ?? ''}',
            mensaje: row['content']?.toString() ?? '',
            fechaRecordatorio: DateTime.fromMillisecondsSinceEpoch(
              alarmTimestamp,
            ),
            modoAviso: row['notification_mode'] == 'alarma'
                ? 'alarma'
                : 'notificacion',
          );
        }
      }
    } catch (error, stackTrace) {
      // A notification failure must not roll back the already-saved note.
      // ignore: avoid_print
      print('[SUPABASE SYNC] No se pudo actualizar la alarma local: $error');
      // ignore: avoid_print
      print(stackTrace);
    }
    return true;
  }

  bool _sameShiftFields(
    Map<String, Object?> local,
    Map<String, dynamic> remote,
  ) {
    return local['datetime']?.toString() == remote['shift_date']?.toString() &&
        local['title'] == remote['title'] &&
        local['description'] == remote['description'] &&
        local['startHour'] == remote['start_hour'] &&
        local['endHour'] == remote['end_hour'] &&
        local['color'] == remote['color'] &&
        remote['is_deleted'] != true;
  }

  bool _sameNoteFields(
    Map<String, Object?> local,
    Map<String, dynamic> remote,
  ) {
    return local['title'] == remote['title'] &&
        local['site'] == remote['site'] &&
        (local['notes'] ?? '') == (remote['content'] ?? '') &&
        (local['startTimeMilliseconds'] as num?)?.toInt() ==
            (remote['start_time_ms'] as num?)?.toInt() &&
        (local['endTimeMilliseconds'] as num?)?.toInt() ==
            (remote['end_time_ms'] as num?)?.toInt() &&
        (local['isImportant'] == 1) == (remote['is_important'] == true) &&
        local['notificationMode'] == remote['notification_mode'] &&
        remote['is_deleted'] != true;
  }

  Future<void> _stopRealtime() async {
    final channel = _channel;
    _channel = null;
    _activeCalendarId = null;
    if (channel != null) {
      await _client.removeChannel(channel);
    }
  }

  Future<void> _saveGroup(
    String id,
    String name, {
    required String ownerUid,
    required bool isOwner,
    required int memberCount,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_savedCalendarIdKey, id);
    await prefs.setString(_savedCalendarNameKey, name);
    await prefs.setString(_savedOwnerIdKey, ownerUid);
    await prefs.setString(_savedRoleKey, isOwner ? 'owner' : 'member');
    await prefs.setInt(_savedMemberCountKey, memberCount);
  }

  Future<SharedCalendarInfo?> _cachedGroup() async {
    final user = currentUser;
    if (user == null) return null;
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getString(_savedCalendarIdKey);
    final name = prefs.getString(_savedCalendarNameKey);
    final owner = prefs.getString(_savedOwnerIdKey);
    final role = prefs.getString(_savedRoleKey);
    if (id == null || name == null || owner == null || role == null) {
      return null;
    }
    return SharedCalendarInfo(
      id: id,
      calendarName: name,
      ownerUid: owner,
      memberCount: prefs.getInt(_savedMemberCountKey) ?? 1,
      isOwner: role == 'owner',
    );
  }

  User _requireUser() {
    final user = currentUser;
    if (user == null) {
      throw StateError('Inicia sesión para sincronizar.');
    }
    return user;
  }

  String _newInviteCode() {
    final random = Random.secure();
    return List.generate(
      12,
      (_) => _codeAlphabet[random.nextInt(_codeAlphabet.length)],
    ).join();
  }

  String _hash(String value) => sha256.convert(utf8.encode(value)).toString();
}

extension on SharedCalendarInfo {
  SharedCalendarInfo copyWith({String? inviteCode}) => SharedCalendarInfo(
    id: id,
    calendarName: calendarName,
    ownerUid: ownerUid,
    memberCount: memberCount,
    isOwner: isOwner,
    inviteCode: inviteCode,
  );
}
