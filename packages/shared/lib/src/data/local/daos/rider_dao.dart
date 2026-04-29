import 'package:drift/drift.dart';
import 'package:shared/shared.dart';
import 'package:shared/src/data/local/database.dart';
import 'package:shared/src/data/local/daos/syncable_dao_mixin.dart';
import 'package:shared/src/domain/entities/rider.dart' as entities;

part 'rider_dao.g.dart';

@DriftAccessor(tables: [Riders])
class RiderDao extends DatabaseAccessor<LogistixDatabase> with _$RiderDaoMixin, SyncableDaoMixin {
  RiderDao(super.db);

  // ── Read Operations ─────────────────────────────────────────────

  Stream<List<entities.Rider>> watchRiders({
    List<String>? statuses,
    String? searchQuery,
    int? limit,
    String? afterFullName,
    String? afterId,
  }) {
    return _buildRidersQuery(
      statuses: statuses,
      searchQuery: searchQuery,
      limit: limit,
      afterFullName: afterFullName,
      afterId: afterId,
    ).watch().map((rows) => rows.map((r) => r.toEntity()).toList());
  }

  Future<List<entities.Rider>> getRiders({
    List<String>? statuses,
    String? searchQuery,
    int? limit,
    String? afterFullName,
    String? afterId,
  }) async {
    final rows = await _buildRidersQuery(
      statuses: statuses,
      searchQuery: searchQuery,
      limit: limit,
      afterFullName: afterFullName,
      afterId: afterId,
    ).get();
    return rows.map((r) => r.toEntity()).toList();
  }

  Selectable<RiderRow> _buildRidersQuery({
    List<String>? statuses,
    String? searchQuery,
    int? limit,
    String? afterFullName,
    String? afterId,
  }) {
    final query = select(db.riders);
    
    if (statuses != null && statuses.isNotEmpty) {
      query.where((r) => r.status.isIn(statuses));
    }
    
    if (searchQuery != null && searchQuery.isNotEmpty) {
      query.where(
        (r) => r.fullName.contains(searchQuery) | r.phoneNumber.contains(searchQuery),
      );
    }

    // Cursor-based pagination
    if (afterFullName != null && afterId != null) {
      query.where((r) => 
        (r.fullName.isBiggerThanValue(afterFullName)) | 
        (r.fullName.equals(afterFullName) & r.id.isBiggerThanValue(afterId))
      );
    }

    query.orderBy([(r) => OrderingTerm.asc(r.fullName), (r) => OrderingTerm.asc(r.id)]);
    
    if (limit != null) {
      query.limit(limit);
    }

    return query;
  }

  Future<entities.Rider?> getRider(String riderId) async {
    final query = select(db.riders)..where((r) => r.id.equals(riderId));
    final row = await query.getSingleOrNull();
    return row?.toEntity();
  }

  Stream<entities.Rider?> watchRider(String riderId) {
    final query = select(db.riders)..where((r) => r.id.equals(riderId));
    return query.watchSingleOrNull().map((row) => row?.toEntity());
  }

  // ── Write Operations ────────────────────────────────────────────

  Future<void> upsertRider(RidersCompanion rider) async {
    await _performUpsert(rider);
  }

  /// Atomically upsert a list of riders in a single transaction.
  Future<void> upsertRiders(List<RidersCompanion> riderList) async {
    if (riderList.isEmpty) return;
    await transaction(() async {
      for (final rider in riderList) {
        await _performUpsert(rider);
      }
    });
  }

  Future<void> _performUpsert(RidersCompanion rider) async {
    await performSyncUpsert(
      table: db.riders,
      companion: rider,
      id: rider.id.present ? rider.id.value : null,
      incomingUpdate: rider.updatedAt.present ? rider.updatedAt.value : null,
      getExistingUpdate: (row) => row.updatedAt,
    );
  }

  Future<void> deleteRider(String id) async {
    await (delete(db.riders)..where((r) => r.id.equals(id))).go();
  }

  Future<void> deleteRiders(List<String> ids) async {
    await (delete(db.riders)..where((r) => r.id.isIn(ids))).go();
  }
}
