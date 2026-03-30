import 'package:drift/drift.dart';
import 'package:shared/src/data/local/database.dart';

part 'captured_order_dao.g.dart';

@DriftAccessor(tables: [CapturedOrders])
class CapturedOrderDao extends DatabaseAccessor<LogistixDatabase>
    with _$CapturedOrderDaoMixin {
  CapturedOrderDao(super.db);

  Future<void> insertCapturedOrders(List<CapturedOrdersCompanion> entries) async {
    await batch((batch) {
      batch.insertAll(db.capturedOrders, entries);
    });
  }

  Future<List<CapturedOrder>> getPendingOrders() {
    return (select(db.capturedOrders)..where((t) => t.isUploaded.equals(false))).get();
  }

  Future<int?> getPendingCount() {
    return (selectOnly(db.capturedOrders)
          ..where(db.capturedOrders.isUploaded.equals(false))
          ..addColumns([db.capturedOrders.id.count()]))
        .map((row) => row.read(db.capturedOrders.id.count()))
        .getSingle();
  }

  Future<void> markAsUploaded(List<int> ids) {
    return (update(db.capturedOrders)..where((t) => t.id.isIn(ids)))
        .write(const CapturedOrdersCompanion(isUploaded: Value(true)));
  }
}
