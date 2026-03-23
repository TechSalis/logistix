import 'package:drift/drift.dart';
import 'package:shared/src/data/local/database.dart';
import 'package:shared/src/data/local/mappers/order_mapper.dart';
import 'package:shared/src/data/local/mappers/rider_mapper.dart';
import 'package:shared/src/domain/entities/order.dart' as entities;

part 'order_dao.g.dart';

@DriftAccessor(tables: [Orders, Riders])
class OrderDao extends DatabaseAccessor<LogistixDatabase> with _$OrderDaoMixin {
  OrderDao(super.db);

  /// Watch orders with advanced filtering and reactive updates from local DB.
  /// Joins with Riders table only when riderId is provided.
  Stream<List<entities.Order>> watchOrders({
    List<entities.OrderStatus>? statuses,
    String? riderId,
    String? createdBy,
    String? searchQuery,
    int limit = 20,
    int offset = 0,
    bool isPrioritySort = false,
    bool includeUnassigned = false,
  }) {
    final conditions = <Expression<bool>>[];

    // 1. Status Filter
    if (statuses != null && statuses.isNotEmpty) {
      final statusStrings = statuses.map((s) => s.value).toList();
      conditions.add(db.orders.status.isIn(statusStrings));
    }

    // 2. Ownership Filter
    if (riderId != null) {
      if (includeUnassigned) {
        conditions.add(
          db.orders.riderId.equals(riderId) |
              db.orders.status.equals(entities.OrderStatus.UNASSIGNED.value),
        );
      } else {
        conditions.add(db.orders.riderId.equals(riderId));
      }
    }

    if (createdBy != null) {
      conditions.add(db.orders.createdBy.equals(createdBy));
    }

    // 3. Search Filter (Tracking number or Address)
    if (searchQuery != null && searchQuery.trim().isNotEmpty) {
      final term = '%${searchQuery.trim().toLowerCase()}%';
      conditions.add(
        db.orders.trackingNumber.lower().like(term) |
            db.orders.pickupAddress.lower().like(term) |
            db.orders.dropOffAddress.lower().like(term),
      );
    }

    final combinedCondition = conditions.isNotEmpty
        ? conditions.reduce((a, b) => a & b)
        : const Constant(true);

    final sorting = [
      if (isPrioritySort)
        OrderingTerm(
          expression: db.orders.status.caseMatch(
            when: {
              Constant(entities.OrderStatus.EN_ROUTE.value): const Constant(0),
              Constant(entities.OrderStatus.ASSIGNED.value): const Constant(1),
              Constant(entities.OrderStatus.UNASSIGNED.value): const Constant(
                2,
              ),
            },
            orElse: const Constant(3),
          ),
        ),
      OrderingTerm.desc(db.orders.createdAt),
    ];

    if (riderId != null) {
      // Logic for Dispatcher or specialized Rider views that need rider info
      final query =
          select(db.orders).join([
              leftOuterJoin(
                db.riders,
                db.riders.id.equalsExp(db.orders.riderId),
              ),
            ])
            ..where(combinedCondition)
            ..orderBy(sorting)
            ..limit(limit, offset: offset);

      return query.map((row) {
        final order = row.readTable(db.orders);
        final rider = row.readTableOrNull(db.riders);
        return order.toEntity(rider: rider?.toEntity());
      }).watch();
    } else {
      // Standard Rider view - no join needed, faster execution
      final query = select(db.orders)
        ..where((_) => combinedCondition)
        ..orderBy(
          sorting.map((e) {
            return (_) => e;
          }).toList(),
        )
        ..limit(limit, offset: offset);

      return query.map((order) {
        return order.toEntity();
      }).watch();
    }
  }

  /// Get single order with its assigned rider.
  Future<entities.Order?> getOrder(String orderId) {
    final query = select(db.orders).join([
      leftOuterJoin(db.riders, db.riders.id.equalsExp(db.orders.riderId)),
    ])..where(db.orders.id.equals(orderId));

    return query.map((row) {
      final order = row.readTable(db.orders);
      final rider = row.readTableOrNull(db.riders);
      return order.toEntity(rider: rider?.toEntity());
    }).getSingleOrNull();
  }

  /// Watch a single order reactively.
  Stream<entities.Order?> watchOrder(String orderId) {
    final query = select(db.orders).join([
      leftOuterJoin(db.riders, db.riders.id.equalsExp(db.orders.riderId)),
    ])..where(db.orders.id.equals(orderId));

    return query.map((row) {
      final order = row.readTable(db.orders);
      final rider = row.readTableOrNull(db.riders);
      return order.toEntity(rider: rider?.toEntity());
    }).watchSingleOrNull();
  }

  /// Watch order count with optional status filters.
  Stream<int> watchOrderCount({List<entities.OrderStatus>? statuses}) {
    var query = selectOnly(db.orders)..addColumns([db.orders.id.count()]);

    if (statuses != null && statuses.isNotEmpty) {
      final statusValues = statuses.map((s) => s.value).toList();
      query = query..where(db.orders.status.isIn(statusValues));
    }

    return query
        .map((row) => row.read(db.orders.id.count()) ?? 0)
        .watchSingle();
  }

  // UPSERT Operations
  Future<void> upsertOrder(OrdersCompanion order) {
    return into(db.orders).insertOnConflictUpdate(order);
  }

  Future<void> upsertOrders(List<OrdersCompanion> orderList) {
    return batch((batch) {
      batch.insertAllOnConflictUpdate(db.orders, orderList);
    });
  }

  // DELETE Operations
  Future<void> deleteOrder(String orderId) {
    return (delete(db.orders)..where((o) => o.id.equals(orderId))).go();
  }

  Future<void> deleteOrders(List<String> orderIds) {
    return (delete(db.orders)..where((o) => o.id.isIn(orderIds))).go();
  }
}
