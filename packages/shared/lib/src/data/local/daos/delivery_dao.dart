// ignore_for_file: cascade_invocations
import 'package:drift/drift.dart';
import 'package:shared/src/data/local/daos/syncable_dao_mixin.dart';
import 'package:shared/src/data/local/database.dart';
import 'package:shared/src/data/local/mappers/delivery_mapper.dart';
import 'package:shared/src/data/local/mappers/rider_mapper.dart';
import 'package:shared/src/domain/entities/delivery.dart' as entities;
import 'package:shared/src/domain/entities/rider.dart' as rider_entities;

part 'delivery_dao.g.dart';

@DriftAccessor(tables: [Deliveries, Riders])
class DeliveryDao extends DatabaseAccessor<LogistixDatabase> with _$DeliveryDaoMixin, SyncableDaoMixin {
  DeliveryDao(super.db);

  // ── Read Operations ─────────────────────────────────────────────

  Stream<List<entities.Delivery>> watchDeliveries({
    List<entities.DeliveryStatus>? statuses,
    String? riderId,
    String? createdBy,
    String? searchQuery,
    bool includeUnassigned = false,
    int limit = 50,
    int offset = 0,
    bool isPrioritySort = false,
  }) {
    final query = _buildDeliveriesQuery(
      statuses: statuses,
      riderId: riderId,
      createdBy: createdBy,
      searchQuery: searchQuery,
      includeUnassigned: includeUnassigned,
    );

    if (isPrioritySort) {
      query.orderBy([
        OrderingTerm.desc(db.deliveries.isPriority),
        OrderingTerm.desc(db.deliveries.createdAt),
      ]);
    } else {
      query.orderBy([OrderingTerm.desc(db.deliveries.createdAt)]);
    }
    
    query.limit(limit, offset: offset);

    return query.map((row) {
      final delivery = row.readTable(db.deliveries);
      final rider = row.readTableOrNull(db.riders);
      return delivery.toEntity(rider: rider?.toEntity());
    }).watch();
  }

  Future<List<entities.Delivery>> getDeliveries({
    List<entities.DeliveryStatus>? statuses,
    String? riderId,
    String? searchQuery,
    int limit = 50,
    int offset = 0,
    DateTime? beforeDate,
    String? beforeId,
  }) {
    final query = _buildDeliveriesQuery(
      statuses: statuses,
      riderId: riderId,
      searchQuery: searchQuery,
    );

    if (beforeDate != null) {
      query.where(db.deliveries.createdAt.isSmallerThanValue(beforeDate));
    }
    // Note: beforeId for cursor pagination is complex to implement without more logic,
    // assuming limit/offset or date is sufficient for now.

    query.orderBy([OrderingTerm.desc(db.deliveries.createdAt)]);
    query.limit(limit, offset: offset);

    return query.map((row) {
      final delivery = row.readTable(db.deliveries);
      final rider = row.readTableOrNull(db.riders);
      return delivery.toEntity(rider: rider?.toEntity());
    }).get();
  }

  Stream<int> watchDeliveryCount({List<entities.DeliveryStatus>? statuses, String? riderId}) {
    final amount = countAll();
    final query = select(db.deliveries).addColumns([amount]);
    
    if (statuses != null && statuses.isNotEmpty) {
      query.where(db.deliveries.status.isIn(statuses.map((s) => s.name).toList()));
    }
    if (riderId != null) {
      query.where(db.deliveries.riderId.equals(riderId));
    }

    return query.map((row) => row.read(amount) ?? 0).watchSingle();
  }

  JoinedSelectStatement<HasResultSet, dynamic> _buildDeliveriesQuery({
    List<entities.DeliveryStatus>? statuses,
    String? riderId,
    String? createdBy,
    String? searchQuery,
    bool includeUnassigned = false,
  }) {
    final query = select(db.deliveries).join([
      leftOuterJoin(db.riders, db.riders.id.equalsExp(db.deliveries.riderId)),
    ]);

    if (statuses != null && statuses.isNotEmpty) {
      query.where(db.deliveries.status.isIn(statuses.map((s) => s.name).toList()));
    }
    
    if (riderId != null) {
      if (includeUnassigned) {
        query.where(
          db.deliveries.riderId.equals(riderId) | 
          db.deliveries.riderId.isNull() |
          (db.deliveries.status.isIn([entities.DeliveryStatus.ASSIGNED.name, entities.DeliveryStatus.EN_ROUTE.name]) & 
           db.riders.status.equals(rider_entities.RiderStatus.OFFLINE.name))
        );
      } else {
        query.where(db.deliveries.riderId.equals(riderId));
      }
    } else if (includeUnassigned) {
      query.where(
        db.deliveries.riderId.isNull() | 
        (db.deliveries.status.isIn([entities.DeliveryStatus.ASSIGNED.name, entities.DeliveryStatus.EN_ROUTE.name]) & 
         db.riders.status.equals(rider_entities.RiderStatus.OFFLINE.name))
      );
    }

    if (createdBy != null) {
      query.where(db.deliveries.createdBy.equals(createdBy));
    }
    
    if (searchQuery != null && searchQuery.isNotEmpty) {
      final term = '%${searchQuery.toLowerCase()}%';
      query.where(
        db.deliveries.trackingNumber.lower().like(term) |
            db.deliveries.dropOffAddress.lower().like(term) |
            db.deliveries.pickupAddress.lower().like(term),
      );
    }
    
    return query;
  }

  Future<entities.Delivery?> getDelivery(String deliveryId) {
    final query = select(db.deliveries).join([
      leftOuterJoin(db.riders, db.riders.id.equalsExp(db.deliveries.riderId)),
    ])..where(db.deliveries.id.equals(deliveryId));

    return query.map((row) {
      final delivery = row.readTable(db.deliveries);
      final rider = row.readTableOrNull(db.riders);
      return delivery.toEntity(rider: rider?.toEntity());
    }).getSingleOrNull();
  }

  Stream<entities.Delivery?> watchDelivery(String deliveryId) {
    final query = select(db.deliveries).join([
      leftOuterJoin(db.riders, db.riders.id.equalsExp(db.deliveries.riderId)),
    ])..where(db.deliveries.id.equals(deliveryId));

    return query.map((row) {
      final delivery = row.readTable(db.deliveries);
      final rider = row.readTableOrNull(db.riders);
      return delivery.toEntity(rider: rider?.toEntity());
    }).watchSingleOrNull();
  }

  // ── Write Operations ────────────────────────────────────────────

  Future<void> upsertDelivery(DeliveriesCompanion delivery) async {
    await _performUpsert(delivery);
  }

  Future<void> upsertDeliveries(List<DeliveriesCompanion> deliveryList) async {
    if (deliveryList.isEmpty) return;
    await transaction(() async {
      for (final delivery in deliveryList) {
        await _performUpsert(delivery);
      }
    });
  }

  Future<void> _performUpsert(DeliveriesCompanion delivery) async {
    await performSyncUpsert(
      table: db.deliveries,
      companion: delivery,
      id: delivery.id.present ? delivery.id.value : null,
      incomingUpdate: delivery.updatedAt.present ? delivery.updatedAt.value : null,
      getExistingUpdate: (row) => row.updatedAt,
    );
  }

  Future<void> deleteDelivery(String id) {
    return (delete(db.deliveries)..where((o) => o.id.equals(id))).go();
  }

  Future<void> deleteDeliveries(List<String> deliveryIds) {
    return (delete(db.deliveries)..where((o) => o.id.isIn(deliveryIds))).go();
  }
}
