import 'package:dispatcher/src/features/chat/data/dtos/chat_message_dto.dart';
import 'package:dispatcher/src/features/chat/data/dtos/conversation_dto.dart';
import 'package:dispatcher/src/features/chat/data/mappers/chat_mapper.dart';
import 'package:shared/shared.dart';

/// Offline cache layer for chat, backed by Drift (SQLite).
///
/// All queries are scoped to [companyId], matching what the backend enforces.
class ChatLocalDataSource {
  ChatLocalDataSource({
    required this.chatDao,
    required this.companyId,
    this.userId,
  });

  final ChatDao chatDao;
  final String companyId;
  final String? userId;

  // ── Conversations ────────────────────────────────────────────────

  Stream<List<ConversationDto>> watchConversations() {
    return chatDao
        .watchConversationsByCompany(companyId)
        .map((entities) => entities.map((e) => e.toDto()).toList());
  }

  Future<void> cacheConversations(List<ConversationDto> dtos) async {
    await chatDao.upsertConversations(
      dtos.map((dto) => dto.toDriftCompanion(companyId)).toList(),
    );
  }

  // ── Messages ─────────────────────────────────────────────────────

  Future<List<ChatMessageDto>> getMessages(
    String conversationId, {
    int limit = 50,
  }) async {
    final entities = await chatDao.getMessagesByConversation(
      conversationId,
      limit: limit,
    );
    return entities.map((e) => e.toDto()).toList();
  }

  Stream<List<ChatMessageDto>> watchMessages(
    String conversationId, {
    int limit = 50,
  }) {
    return chatDao
        .watchMessagesByConversation(conversationId, limit: limit)
        .map((entities) => entities.map((e) => e.toDto()).toList());
  }

  Future<void> cacheMessages(List<ChatMessageDto> dtos) async {
    await chatDao.upsertMessages(
      dtos.map((dto) => dto.toDriftCompanion()).toList(),
    );
  }

  Future<void> cacheMessage(ChatMessageDto dto) async {
    await chatDao.transaction(() async {
      final companion = dto.toDriftCompanion();
      await chatDao.upsertMessage(companion);

      // CRITICAL: Update the conversation's lastMessage fields to ensure
      // the list reorders and shows the latest snippet reactively.
      await chatDao.updateConversationLastMessage(
        conversationId: dto.conversationId,
        messageId: dto.id,
        body: dto.body,
        at: dto.createdAt,
        senderType: dto.senderType.name,
      );
    });
  }

  Future<void> softDeleteMessage(String messageId) =>
      chatDao.softDeleteMessage(messageId);

  Future<void> replaceTempMessage(String tempId, ChatMessageDto real) async {
    await chatDao.transaction(() async {
      final companion = real.toDriftCompanion();
      await chatDao.replaceTempMessage(tempId, companion);

      // Also ensure conversation last message is updated with the real message data
      await chatDao.updateConversationLastMessage(
        conversationId: real.conversationId,
        messageId: real.id,
        body: real.body,
        at: real.createdAt,
        senderType: real.senderType.name,
      );
    });
  }
}
