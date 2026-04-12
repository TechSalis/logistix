import 'package:dispatcher/src/domain/usecases/sync_dispatcher_data_usecase.dart';
import 'package:shared/shared.dart';

/// Component that performs the heavy lifting of data synchronization.
class DispatcherSyncComponent extends SessionComponent {
  DispatcherSyncComponent(this._syncUseCase, this._database);

  final SyncDispatcherDataUseCase _syncUseCase;
  final LogistixDatabase _database;
  bool _isSyncing = false;

  @override
  String get id => 'dispatcher_sync';

  @override
  Future<void> start() async {}

  @override
  Future<void> sync() async {
    if (_isSyncing) return;
    _isSyncing = true;

    try {
      final lastSyncTime = await _database.getLastSyncTime(
        SyncKeys.dispatcherLastSync,
      );
      final since = lastSyncTime?.millisecondsSinceEpoch.toDouble();
      await _syncUseCase(since: since);
    } finally {
      _isSyncing = false;
    }
  }

  @override
  Future<void> stop() async {}
}
