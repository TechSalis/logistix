import 'dart:async';

import 'package:drift/drift.dart';
import 'package:shared/src/data/local/database.dart';
import 'package:shared/src/data/local/mappers/chat_mapper.dart';

part 'chat_dao.g.dart';

@DriftAccessor(tables: [Conversations, ChatMessages])
class ChatDao extends DatabaseAccessor<LogistixDatabase> {
  ChatDao(super.db);

  // ── Conversations ────────────────────────────────────────────────

  Stream<List<Conversation>> watchConversationsByCompany(
    String companyId, {
    int limit = 50,
  }) {
    return (select(db.conversations)
          ..where((c) => c.companyId.equals(companyId))
          ..orderBy([(t) => OrderingTerm.desc(t.lastMessageAt)])
          ..limit(limit))
        .watch()
        .map((rows) => rows.map((r) => r.toEntity()).toList());
  }

  Future<List<Conversation>> getConversationsPaginated({
    required String companyId,
    required int offset,
    required int limit,
  }) async {
    final rows = await (select(db.conversations)
          ..where((c) => c.companyId.equals(companyId))
          ..orderBy([(t) => OrderingTerm.desc(t.lastMessageAt)])
          ..limit(limit, offset: offset))
        .get();
    return rows.map((r) => r.toEntity()).toList();
  }

  Future<Conversation?> getConversationById(String conversationId) async {
    final row = await (select(db.conversations)
          ..where((c) => c.id.equals(conversationId)))
        .getSingleOrNull();
    return row?.toEntity();
  }

  // ── Messages ─────────────────────────────────────────────────────

  Future<List<ChatMessage>> getMessagesByConversation(
    String conversationId, {
    int limit = 50,
  }) async {
    final rows = await (select(db.chatMessages)
          ..where((m) => m.conversationId.equals(conversationId) & m.isDeleted.not())
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)])
          ..limit(limit))
        .get();
    return rows.map((r) => r.toEntity()).toList();
  }

  Stream<List<ChatMessage>> watchMessagesByConversation(
    String conversationId, {
    int limit = 50,
  }) {
    return (select(db.chatMessages)
          ..where((m) => m.conversationId.equals(conversationId) & m.isDeleted.not())
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)])
          ..limit(limit))
        .watch()
        .map((rows) => rows.map((r) => r.toEntity()).toList());
  }

  // ── Persistence ──────────────────────────────────────────────────

  Future<void> upsertConversation(ConversationsCompanion companion) async {
    final id = companion.id.value;

    await transaction(() async {
      final existing = await (select(db.conversations)..where((c) => c.id.equals(id))).getSingleOrNull();
      
      final shouldUpdate = existing == null || 
          (companion.updatedAt.present && companion.updatedAt.value.isAfter(existing.updatedAt));

      if (shouldUpdate) {
        await into(db.conversations).insertOnConflictUpdate(companion);
      }
    });
  }

  Future<void> upsertMessage(ChatMessagesCompanion companion) =>
      into(db.chatMessages).insertOnConflictUpdate(companion);

  Future<void> upsertConversations(List<ConversationsCompanion> companions) async {
    await batch((batch) {
      for (final companion in companions) {
        batch.insert(db.conversations, companion, mode: InsertMode.insertOrReplace);
      }
    });
  }

  Future<void> upsertMessages(List<ChatMessagesCompanion> companions) async {
    await batch((batch) {
      for (final companion in companions) {
        batch.insert(db.chatMessages, companion, mode: InsertMode.insertOrReplace);
      }
    });
  }

  Future<void> softDeleteMessage(String messageId) =>
      softDeleteMessages([messageId]);

  Future<void> softDeleteMessages(List<String> messageIds) =>
      (update(db.chatMessages)..where((m) => m.id.isIn(messageIds))).write(
        const ChatMessagesCompanion(isDeleted: Value(true)),
      );

  Future<void> replaceTempMessage(String tempId, ChatMessagesCompanion real) {
    return transaction(() async {
      await (delete(db.chatMessages)..where((m) => m.id.equals(tempId))).go();
      await upsertMessage(real);
    });
  }

  Future<void> updateConversationLastMessage({
    required String conversationId,
    required String messageId,
    required String body,
    required DateTime at,
    required String senderType,
  }) {
    return transaction(() async {
      final existing = await (select(db.conversations)
            ..where((c) => c.id.equals(conversationId)))
          .getSingleOrNull();

      if (existing == null) return;

      // Only update if this message is the same as the last message (status update)
      // or if it's newer than the current last message
      if (existing.lastMessageId == messageId ||
          at.isAfter(existing.lastMessageAt)) {
        await (update(db.conversations)..where((c) => c.id.equals(conversationId)))
            .write(
          ConversationsCompanion(
            lastMessageId: Value(messageId),
            lastMessageBody: Value(body),
            lastMessageAt: Value(at),
            lastMessageSenderType: Value(senderType),
          ),
        );
      }
    });
  }

  Future<void> clearAll() async {
    await transaction(() async {
      await delete(db.conversations).go();
      await delete(db.chatMessages).go();
    });
  }
}
