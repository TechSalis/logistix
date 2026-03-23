import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'database.g.dart';

// Tables
class Orders extends Table {
  TextColumn get id => text()();
  TextColumn get pickupAddress => text().nullable()();
  RealColumn get pickupLat => real().nullable()();
  RealColumn get pickupLng => real().nullable()();
  TextColumn get pickupPlaceId => text().nullable()();
  TextColumn get dropOffAddress => text()();
  RealColumn get dropOffLat => real().nullable()();
  RealColumn get dropOffLng => real().nullable()();
  TextColumn get dropOffPlaceId => text().nullable()();
  TextColumn get riderId => text().nullable()();
  RealColumn get codAmount => real().nullable()();
  TextColumn get pickupPhone => text().nullable()();
  TextColumn get dropOffPhone => text().nullable()();
  TextColumn get description => text().nullable()();
  TextColumn get trackingNumber => text()();
  TextColumn get status =>
      text()(); // UNASSIGNED, ASSIGNED, EN_ROUTE, DELIVERED, CANCELLED
  DateTimeColumn get deliveredAt => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime().nullable()();
  DateTimeColumn get localUpdatedAt => dateTime()(); // For delta sync

  @override
  Set<Column> get primaryKey => {id};
}

class Dispatchers extends Table {
  TextColumn get id => text()(); // userId
  TextColumn get email => text()();
  TextColumn get fullName => text()();
  TextColumn get companyId => text().nullable()();
  TextColumn get phoneNumber => text().nullable()();
  TextColumn get role => text().withDefault(const Constant('DISPATCHER'))();
  BoolColumn get isOnboarded => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime().nullable()();
  DateTimeColumn get updatedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class Riders extends Table {
  TextColumn get id => text()();
  TextColumn get email => text()();
  TextColumn get fullName => text()();
  TextColumn get companyId => text()();
  TextColumn get status => text()(); // OFFLINE, ONLINE, BUSY
  TextColumn get phoneNumber => text().nullable()();
  TextColumn get fcmToken => text().nullable()();
  TextColumn get role => text().withDefault(const Constant('RIDER'))();
  BoolColumn get isOnboarded => boolean().withDefault(const Constant(true))();
  RealColumn get lastLat => real().nullable()();
  RealColumn get lastLng => real().nullable()();
  IntColumn get batteryLevel => integer().nullable()();
  BoolColumn get isAccepted => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().nullable()();
  DateTimeColumn get updatedAt => dateTime().nullable()();
  DateTimeColumn get localUpdatedAt => dateTime()(); // For delta sync

  @override
  Set<Column> get primaryKey => {id};
}

class SyncMetadata extends Table {
  TextColumn get key =>
      text()(); // e.g., 'dispatcher_last_sync', 'rider_last_sync'
  DateTimeColumn get lastSyncTimestamp => dateTime()();
  TextColumn get sessionId => text().nullable()(); // Track which session synced

  @override
  Set<Column> get primaryKey => {key};
}

@DriftDatabase(tables: [Orders, Riders, Dispatchers, SyncMetadata])
class LogistixDatabase extends _$LogistixDatabase {
  LogistixDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 7;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onUpgrade: (m, from, to) async {
      if (from < 7) {
        // Development-era reset: nuke all tables and recreate 
        // dropping columns in SQLite requires table rebuild anyway
        for (final table in allTables) {
          await m.drop(table);
        }
        await m.createAll();
      }
    },
  );

  // Sync Metadata
  Future<DateTime?> getLastSyncTime(String key) async {
    final result = await (select(
      syncMetadata,
    )..where((s) => s.key.equals(key))).getSingleOrNull();
    return result?.lastSyncTimestamp;
  }

  Future<void> updateLastSyncTime(
    String key,
    DateTime timestamp,
    String? sessionId,
  ) {
    return into(syncMetadata).insertOnConflictUpdate(
      SyncMetadataCompanion.insert(
        key: key,
        lastSyncTimestamp: timestamp,
        sessionId: Value(sessionId),
      ),
    );
  }

  Future<void> clear() async {
    await Future.wait([
      delete(orders).go(),
      delete(riders).go(),
      delete(dispatchers).go(),
      delete(syncMetadata).go(),
    ]);
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'logistix.db'));
    return NativeDatabase.createInBackground(file);
  });
}
