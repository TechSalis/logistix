import 'package:rider/src/domain/usecases/sync_rider_data_usecase.dart';
import 'package:shared/shared.dart';

/// Component that performs the heavy lifting of rider data synchronization.
class RiderSyncComponent extends SessionComponent {
  RiderSyncComponent(this._syncUseCase, this._database);

  final SyncRiderDataUseCase _syncUseCase;
  final LogistixDatabase _database;
  bool _isSyncing = false;

  @override
  String get id => 'rider_sync';

  @override
  Future<void> start() async {
    await sync();
  }

  @override
  Future<void> sync() async {
    if (_isSyncing) return;
    _isSyncing = true;

    try {
      final lastSyncTime = await _database.getLastSyncTime(
        SyncKeys.riderLastSync,
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
