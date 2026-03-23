import 'package:drift/drift.dart';
import 'package:shared/src/data/local/database.dart';
import 'package:shared/src/data/local/mappers/rider_mapper.dart';
import 'package:shared/src/domain/entities/rider.dart' as entities;

part 'rider_dao.g.dart';

@DriftAccessor(tables: [Riders])
class RiderDao extends DatabaseAccessor<LogistixDatabase> with _$RiderDaoMixin {
  RiderDao(super.db);

  Stream<List<entities.Rider>> watchRiders({
    List<String>? statuses,
    String? searchQuery,
  }) {
    final query = select(db.riders);

    if (statuses != null && statuses.isNotEmpty) {
      query.where((r) => r.status.isIn(statuses));
    }

    if (searchQuery != null && searchQuery.isNotEmpty) {
      query.where((r) =>
        r.fullName.contains(searchQuery) |
        r.email.contains(searchQuery) |
        r.phoneNumber.contains(searchQuery),
      );
    }

    query.orderBy([(r) => OrderingTerm.asc(r.fullName)]);

    return query.watch().map((rows) {
      return rows.map((row) => row.toEntity()).toList();
    });
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

  Future<List<entities.Rider>> searchRiders({
    String? searchQuery,
    List<String>? statuses,
  }) async {
    final query = select(db.riders)..where((r) => r.isAccepted.equals(true));

    if (statuses != null && statuses.isNotEmpty) {
      query.where((r) => r.status.isIn(statuses));
    }

    if (searchQuery != null && searchQuery.isNotEmpty) {
      query.where((r) =>
        r.fullName.contains(searchQuery) |
        r.email.contains(searchQuery) |
        r.phoneNumber.contains(searchQuery),
      );
    }

    query.orderBy([(r) => OrderingTerm.asc(r.fullName)]);

    final rows = await query.get();
    return rows.map((row) => row.toEntity()).toList();
  }

  Future<void> upsertRider(RidersCompanion rider) {
    return into(db.riders).insertOnConflictUpdate(rider);
  }

  Future<void> upsertRiders(List<RidersCompanion> list) async {
    await batch((batch) {
      batch.insertAllOnConflictUpdate(db.riders, list);
    });
  }

  Future<int> deleteRider(String id) {
    return (delete(db.riders)..where((r) => r.id.equals(id))).go();
  }

  Future<void> deleteRiders(List<String> ids) async {
    await (delete(db.riders)..where((r) => r.id.isIn(ids))).go();
  }
}
