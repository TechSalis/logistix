import 'package:drift/drift.dart';
import 'package:shared/src/data/local/database.dart';
import 'package:shared/src/data/local/mappers/order_mapper.dart';
import 'package:shared/src/data/local/mappers/rider_mapper.dart';
import 'package:shared/src/domain/entities/order.dart' as entities;

part 'order_dao.g.dart';

@DriftAccessor(tables: [Orders, Riders])
class OrderDao extends DatabaseAccessor<LogistixDatabase> with _$OrderDaoMixin {
  OrderDao(super.db);

  // ── Read Operations ─────────────────────────────────────────────

  Stream<List<entities.Order>> watchOrders({
    List<entities.OrderStatus>? statuses,
    String? riderId,
    String? createdBy,
    String? searchQuery,
    bool includeUnassigned = false,
    int limit = 50,
    int offset = 0,
    bool isPrioritySort = false,
  }) {
    final query = _buildOrdersQuery(
      statuses: statuses,
      riderId: riderId,
      createdBy: createdBy,
      searchQuery: searchQuery,
      includeUnassigned: includeUnassigned,
    );

    if (isPrioritySort) {
      query.orderBy([
        OrderingTerm.desc(db.orders.isPriority),
        OrderingTerm.desc(db.orders.createdAt),
      ]);
    } else {
      query.orderBy([OrderingTerm.desc(db.orders.createdAt)]);
    }
    
    query.limit(limit, offset: offset);

    return query.map((row) {
      final order = row.readTable(db.orders);
      final rider = row.readTableOrNull(db.riders);
      return order.toEntity(rider: rider?.toEntity());
    }).watch();
  }

  Future<List<entities.Order>> getOrders({
    List<entities.OrderStatus>? statuses,
    String? riderId,
    String? searchQuery,
    int limit = 50,
    int offset = 0,
    DateTime? beforeDate,
    String? beforeId,
  }) {
    final query = _buildOrdersQuery(
      statuses: statuses,
      riderId: riderId,
      searchQuery: searchQuery,
    );

    if (beforeDate != null) {
      query.where(db.orders.createdAt.isSmallerThanValue(beforeDate));
    }
    // Note: beforeId for cursor pagination is complex to implement without more logic,
    // assuming limit/offset or date is sufficient for now.

    query.orderBy([OrderingTerm.desc(db.orders.createdAt)]);
    query.limit(limit, offset: offset);

    return query.map((row) {
      final order = row.readTable(db.orders);
      final rider = row.readTableOrNull(db.riders);
      return order.toEntity(rider: rider?.toEntity());
    }).get();
  }

  Stream<int> watchOrderCount({List<entities.OrderStatus>? statuses, String? riderId}) {
    final amount = countAll();
    final query = select(db.orders).addColumns([amount]);
    
    if (statuses != null && statuses.isNotEmpty) {
      query.where(db.orders.status.isIn(statuses.map((s) => s.value).toList()));
    }
    if (riderId != null) {
      query.where(db.orders.riderId.equals(riderId));
    }

    return query.map((row) => row.read(amount) ?? 0).watchSingle();
  }

  JoinedSelectStatement<HasResultSet, dynamic> _buildOrdersQuery({
    List<entities.OrderStatus>? statuses,
    String? riderId,
    String? createdBy,
    String? searchQuery,
    bool includeUnassigned = false,
  }) {
    final query = select(db.orders).join([
      leftOuterJoin(db.riders, db.riders.id.equalsExp(db.orders.riderId)),
    ]);

    if (statuses != null && statuses.isNotEmpty) {
      query.where(db.orders.status.isIn(statuses.map((s) => s.value).toList()));
    }
    
    if (riderId != null) {
      if (includeUnassigned) {
        query.where(db.orders.riderId.equals(riderId) | db.orders.riderId.isNull());
      } else {
        query.where(db.orders.riderId.equals(riderId));
      }
    }

    if (createdBy != null) {
      query.where(db.orders.createdBy.equals(createdBy));
    }
    
    if (searchQuery != null && searchQuery.isNotEmpty) {
      final term = '%${searchQuery.toLowerCase()}%';
      query.where(
        db.orders.trackingNumber.lower().like(term) |
            db.orders.dropOffAddress.lower().like(term) |
            db.orders.pickupAddress.lower().like(term),
      );
    }
    
    return query;
  }

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

  // ── Write Operations ────────────────────────────────────────────

  Future<void> upsertOrder(OrdersCompanion order) async {
    await _performUpsert(order);
  }

  Future<void> upsertOrders(List<OrdersCompanion> orderList) async {
    if (orderList.isEmpty) return;
    await transaction(() async {
      for (final order in orderList) {
        await _performUpsert(order);
      }
    });
  }

  Future<void> _performUpsert(OrdersCompanion order) async {
    final id = order.id.value;
    final incomingUpdate = order.updatedAt.value;

    if (incomingUpdate == null) {
      await into(db.orders).insertOnConflictUpdate(order);
      return;
    }

    final existing = await (select(db.orders)..where((o) => o.id.equals(id)))
        .getSingleOrNull();

    if (existing == null ||
        existing.updatedAt == null ||
        incomingUpdate.isAfter(existing.updatedAt!)) {
      await into(db.orders).insertOnConflictUpdate(order);
    }
  }

  Future<void> deleteOrder(String id) {
    return (delete(db.orders)..where((o) => o.id.equals(id))).go();
  }

  Future<void> deleteOrders(List<String> orderIds) {
    return (delete(db.orders)..where((o) => o.id.isIn(orderIds))).go();
  }
}
