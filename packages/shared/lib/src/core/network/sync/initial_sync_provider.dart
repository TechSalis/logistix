import 'dart:async';

/// Interface for module-specific initial synchronization logic.
///
/// This is used by the centralized [SyncPage] to perform the catch-up sync
/// before routing the user to their dashboard.
abstract class InitialSyncProvider {
  /// Entry point for performing initial sync (e.g., fetching profile, catching up orders/metrics).
  Future<void> performInitialSync();
}
