import 'package:adapters/adapters.dart';
import 'package:customer/src/domain/usecases/sync_customer_data_usecase.dart';
import 'package:shared/shared.dart';

/// Performs the initial data synchronization for the Customer module.
class CustomerInitialSyncProvider implements InitialSyncProvider {
  CustomerInitialSyncProvider({
    required LogistixDatabase database,
    required SyncCustomerDataUseCase syncCustomerDataUseCase,
  }) : _database = database,
       _syncCustomerDataUseCase = syncCustomerDataUseCase;

  final LogistixDatabase _database;
  final SyncCustomerDataUseCase _syncCustomerDataUseCase;

  @override
  Future<void> performInitialSync() async {
    final lastSyncTime = await _database.getLastSyncTime(
      'customer_last_sync',
    );

    final since = lastSyncTime?.millisecondsSinceEpoch.toDouble();

    try {
      await _syncCustomerDataUseCase(since: since);
    } catch (e, s) {
      appLogger.exception(e, stack: s);
    }
  }
}
