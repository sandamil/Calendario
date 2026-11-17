import 'dart:async';

class SyncEvents {
  SyncEvents._();

  static final SyncEvents instance = SyncEvents._();

  final StreamController<void> _remoteController =
      StreamController<void>.broadcast();
  final StreamController<void> _localController =
      StreamController<void>.broadcast();

  Stream<void> get changes => _remoteController.stream;
  Stream<void> get localChanges => _localController.stream;

  void notify() {
    if (!_remoteController.isClosed) _remoteController.add(null);
  }

  void notifyLocalChange() {
    if (!_localController.isClosed) _localController.add(null);
  }
}
