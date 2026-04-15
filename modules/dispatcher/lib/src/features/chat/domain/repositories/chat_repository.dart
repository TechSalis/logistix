import 'package:bootstrap/definitions/app_error.dart';
import 'package:bootstrap/definitions/result.dart';
import 'package:shared/shared.dart';

/// Strategic, minimal, reactive Repository for Logistix Chat.
abstract class ChatRepository {
  String? get currentUserId;

  // ── Reactive Data ────────────────────────────────────────────────
  Future<Conversation?> getConversation(String id);

  /// Real-time stream of all conversations for the active dispatcher scope.
  Stream<List<Conversation>> watchConversations({int limit = 50});

  /// Real-time stream of messages for a specific conversation.
  Stream<List<ChatMessage>> watchMessages(String conversationId, {int? limit});

  /// Live typing events for a conversation.
  Stream<TypingStatus?> watchTyping(String conversationId);

  // ── Actions ─────────────────────────────────────────────────────

  Future<Result<AppError, ChatMessage>> sendManualMessage({
    required String conversationId,
    required String body,
  });

  Future<Result<AppError, ChatMessage>> sendMediaMessage({
    required String conversationId,
    required String mediaUrl,
    String? caption,
  });

  Future<Result<AppError, bool>> toggleAutoReply({
    required String conversationId,
    required bool enabled,
  });

  Future<Result<AppError, ChatMessage>> deleteMessage(String messageId);
  Future<Result<AppError, bool>> sendTypingIndicator(String conversationId);

  /// Forces a manual synchronization for a specific conversation.
  Future<Result<AppError, void>> syncMessages(String conversationId);

  /// Performs a delta synchronization for all conversations.
  Future<Result<AppError, void>> syncConversations();
}
