// ignore_for_file: constant_identifier_names
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:shared/shared.dart';

part 'database.g.dart';

// ── Tables ─────────────────────────────────────────────────────────

@TableIndex(name: 'idx_orders_status_date', columns: {#status, #createdAt})
@TableIndex(name: 'idx_orders_priority_date', columns: {#isPriority, #createdAt})
@DataClassName('OrderRow')
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
  TextColumn get companyId => text().nullable()();
  TextColumn get assignedCompanyId => text().nullable()();
  TextColumn get description => text().nullable()();
  TextColumn get trackingNumber => text()();
  TextColumn get status => text()(); 
  TextColumn get createdBy => text().nullable()();
  DateTimeColumn get scheduledAt => dateTime().nullable()();
  DateTimeColumn get deliveredAt => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime().nullable()();
  DateTimeColumn get localUpdatedAt => dateTime()(); // For delta sync
  BoolColumn get isPriority => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('DispatcherRow')
class Dispatchers extends Table {
  TextColumn get id => text()(); // userId
  TextColumn get email => text()();
  TextColumn get fullName => text()();
  TextColumn get companyId => text().nullable()();
  TextColumn get phoneNumber => text().nullable()();
  TextColumn get role => text().withDefault(Constant(UserRole.DISPATCHER.name))();
  BoolColumn get isOnboarded => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime().nullable()();
  DateTimeColumn get updatedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('RiderRow')
class Riders extends Table {
  TextColumn get id => text()();
  TextColumn get email => text()();
  TextColumn get fullName => text()();
  TextColumn get companyId => text()();
  TextColumn get status => text()(); // OFFLINE, ONLINE, BUSY
  TextColumn get permitStatus => text().withDefault(Constant(PermitStatus.PENDING.name))();
  TextColumn get phoneNumber => text().nullable()();
  TextColumn get role => text().withDefault(Constant(UserRole.RIDER.name))();
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

@DataClassName('SyncMetadataRow')
class SyncMetadata extends Table {
  TextColumn get key => text()(); 
  DateTimeColumn get lastSyncTimestamp => dateTime()();
  TextColumn get sessionId => text().nullable()();

  @override
  Set<Column> get primaryKey => {key};
}

@TableIndex(name: 'idx_conversations_org_feed', columns: {#companyId, #lastMessageAt})
@DataClassName('ConversationRow')
class Conversations extends Table {
  TextColumn get id => text()();
  TextColumn get platform => text()();
  TextColumn get platformId => text()();
  DateTimeColumn get lastMessageAt => dateTime()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  BoolColumn get autoReplyEnabled => boolean().withDefault(const Constant(true))();
  TextColumn get customerName => text().nullable()();
  TextColumn get companyId => text()();
  
  TextColumn get lastMessageId => text().nullable()();
  TextColumn get lastMessageBody => text().nullable()();
  TextColumn get lastMessageSenderType => text().nullable()();
  BoolColumn get lastMessageIsDeleted => boolean().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@TableIndex(name: 'idx_messages_conversation_feed', columns: {#conversationId, #isDeleted, #createdAt})
@DataClassName('ChatMessageRow')
class ChatMessages extends Table {
  TextColumn get id => text()();
  TextColumn get conversationId => text()();
  TextColumn get body => text()();
  TextColumn get senderType => text()();
  TextColumn get senderId => text().nullable()();
  TextColumn get senderName => text().nullable()();
  TextColumn get mediaUrl => text().nullable()();
  TextColumn get parentId => text().nullable()();
  TextColumn get staleParentId => text().nullable()();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  TextColumn get externalId => text().nullable()();
  TextColumn get status => text().withDefault(Constant(MessageStatus.SENT.name))();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

// ── Database Implementation ────────────────────────────────────────

@DriftDatabase(
  tables: [Orders, Riders, Dispatchers, SyncMetadata, Conversations, ChatMessages],
  daos: [OrderDao, RiderDao, ChatDao],
)
class LogistixDatabase extends _$LogistixDatabase {
  LogistixDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async => m.createAll(),
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            await m.createTable(conversations);
            await m.createTable(chatMessages);
          }
          if (from < 3) {
            // Using raw SQL migration to bypass missing GeneratedColumn types in a manual environment
            await customStatement('ALTER TABLE orders ADD COLUMN is_priority INTEGER DEFAULT 0;');
          }
        },
        beforeOpen: (details) async {
          if (details.wasCreated) {
            // Initial data if needed
          }
        },
      );

  // Sync Metadata Helpers
  Future<DateTime?> getLastSyncTime(String key) async {
    final result = await (select(syncMetadata)..where((s) => s.key.equals(key))).getSingleOrNull();
    return result?.lastSyncTimestamp;
  }

  Future<void> updateLastSyncTime(String key, DateTime timestamp, String? sessionId) {
    return into(syncMetadata).insertOnConflictUpdate(
      SyncMetadataCompanion.insert(
        key: key,
        lastSyncTimestamp: timestamp,
        sessionId: Value(sessionId),
      ),
    );
  }

  /// Atomic wipe of all user data.
  Future<void> clearAllData() async {
    await transaction(() async {
      await batch((batch) {
        batch
          ..deleteWhere(orders, (_) => const Constant(true))
          ..deleteWhere(riders, (_) => const Constant(true))
          ..deleteWhere(dispatchers, (_) => const Constant(true))
          ..deleteWhere(syncMetadata, (_) => const Constant(true))
          ..deleteWhere(conversations, (_) => const Constant(true))
          ..deleteWhere(chatMessages, (_) => const Constant(true));
      });
    });
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'logistix.db'));
    return NativeDatabase.createInBackground(file);
  });
}

// ── Manual Entity Classes (Replacement for Generated Drift Classes) ─────

class MessageMetadata {
  const MessageMetadata({this.latitude, this.longitude});
  final double? latitude;
  final double? longitude;
}

enum SenderType { DISPATCHER, CUSTOMER, AGENT, SYSTEM }

enum MessageStatus { PENDING, SENT, DELIVERED, READ, FAILED }

class TypingStatus {
  const TypingStatus({
    required this.conversationId,
    required this.isTyping,
    this.senderId,
    this.senderType,
  });

  final String conversationId;
  final bool isTyping;
  final String? senderId;
  final SenderType? senderType;
}

class Conversation {

  const Conversation({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.companyId,
    required this.platformId,
    this.autoReplyEnabled = true,
    this.customerName,
    this.lastMessageId,
    this.lastMessageBody,
    this.lastMessageSenderType,
    this.lastMessageIsDeleted,
    this.platform = ChatPlatform.WHATSAPP,
  });
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool autoReplyEnabled;
  final String? customerName;
  final String companyId;
  final String? lastMessageId;
  final String? lastMessageBody;
  final SenderType? lastMessageSenderType;
  final bool? lastMessageIsDeleted;
  final ChatPlatform platform;
  final String platformId;

  DateTime get lastMessageAt => updatedAt;
  String? get lastMessage => lastMessageBody;

  Conversation copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? autoReplyEnabled,
    String? customerName,
    String? companyId,
    String? lastMessageId,
    String? lastMessageBody,
    SenderType? lastMessageSenderType,
    bool? lastMessageIsDeleted,
    ChatPlatform? platform,
    String? platformId,
  }) {
    return Conversation(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      autoReplyEnabled: autoReplyEnabled ?? this.autoReplyEnabled,
      customerName: customerName ?? this.customerName,
      companyId: companyId ?? this.companyId,
      lastMessageId: lastMessageId ?? this.lastMessageId,
      lastMessageBody: lastMessageBody ?? this.lastMessageBody,
      lastMessageSenderType:
          lastMessageSenderType ?? this.lastMessageSenderType,
      lastMessageIsDeleted: lastMessageIsDeleted ?? this.lastMessageIsDeleted,
      platform: platform ?? this.platform,
      platformId: platformId ?? this.platformId,
    );
  }
}

class ChatMessage {

  const ChatMessage({
    required this.id,
    required this.conversationId,
    required this.body,
    required this.senderType,
    required this.createdAt, this.senderId,
    this.senderName,
    this.mediaUrl,
    this.parentId,
    this.staleParentId,
    this.isDeleted = false,
    this.externalId,
    this.status = MessageStatus.SENT,
    this.metadata,
  });
  final String id;
  final String conversationId;
  final String body;
  final SenderType senderType;
  final String? senderId;
  final String? senderName;
  final String? mediaUrl;
  final String? parentId;
  final String? staleParentId;
  final bool isDeleted;
  final String? externalId;
  final MessageStatus status;
  final DateTime createdAt;
  final MessageMetadata? metadata;

  ChatMessage copyWith({
    String? id,
    String? conversationId,
    String? body,
    SenderType? senderType,
    String? senderId,
    String? senderName,
    String? mediaUrl,
    String? parentId,
    String? staleParentId,
    bool? isDeleted,
    String? externalId,
    MessageStatus? status,
    DateTime? createdAt,
    MessageMetadata? metadata,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      conversationId: conversationId ?? this.conversationId,
      body: body ?? this.body,
      senderType: senderType ?? this.senderType,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      mediaUrl: mediaUrl ?? this.mediaUrl,
      parentId: parentId ?? this.parentId,
      staleParentId: staleParentId ?? this.staleParentId,
      isDeleted: isDeleted ?? this.isDeleted,
      externalId: externalId ?? this.externalId,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      metadata: metadata ?? this.metadata,
    );
  }
}
