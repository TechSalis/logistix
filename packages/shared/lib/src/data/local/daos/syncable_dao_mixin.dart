import 'package:drift/drift.dart';
import 'package:shared/src/data/local/database.dart';

/// A mixin for DAOs that need to handle synchronized upserts with timestamp-based conflict resolution.
mixin SyncableDaoMixin on DatabaseAccessor<LogistixDatabase> {
  /// Safely performs an upsert by checking if the incoming [companion] is newer 
  /// than the [existing] row.
  Future<void> performSyncUpsert<T extends Table, D extends DataClass>({
    required TableInfo<T, D> table,
    required UpdateCompanion<D> companion,
    required String? id,
    required DateTime? incomingUpdate,
    required DateTime? Function(D) getExistingUpdate,
  }) async {
    // 1. If no ID or no timestamp, just standard upsert
    if (id == null || incomingUpdate == null) {
      await into(table).insertOnConflictUpdate(companion);
      return;
    }

    // 2. Check existing record
    final existing = await (select(table)..where((t) {
      // This is a bit tricky with generic tables, but we know our tables use 'id' as primary key
      final idColumn = table.columnsByName['id'] as Column<String>;
      return idColumn.equals(id);
    })).getSingleOrNull();

    // 3. Conditional Update: Only if existing is missing or incoming is newer
    final existingUpdate = existing != null ? getExistingUpdate(existing) : null;
    
    if (existing == null || existingUpdate == null || incomingUpdate.isAfter(existingUpdate)) {
      await into(table).insertOnConflictUpdate(companion);
    }
  }
}
