import 'dart:async';

import 'package:bootstrap/definitions/app_error.dart';
import 'package:bootstrap/definitions/result.dart';
import 'package:dispatcher/src/features/chat/data/datasources/chat_local_datasource.dart';
import 'package:dispatcher/src/features/chat/data/datasources/chat_remote_datasource.dart';
import 'package:dispatcher/src/features/chat/data/dtos/chat_message_dto.dart';
import 'package:dispatcher/src/features/chat/data/dtos/get_conversations_request.dart';
import 'package:dispatcher/src/features/chat/data/dtos/get_messages_request.dart';
import 'package:dispatcher/src/features/chat/data/dtos/send_media_message_request.dart';
import 'package:dispatcher/src/features/chat/data/dtos/send_message_request.dart';
import 'package:dispatcher/src/features/chat/data/dtos/toggle_ai_request.dart';
import 'package:dispatcher/src/features/chat/domain/repositories/chat_repository.dart';
import 'package:dispatcher/src/features/chat/domain/usecases/chat_session_manager.dart';
import 'package:shared/shared.dart';

/// Strategic, minimal, reactive Repository for Logistix Chat.
///
/// Refined to follow the strict SSOT (Single Source of Truth) pattern:
/// - UI observes the Local DB directly.
/// - ChatSessionManager handles all background synchronization.
class ChatRepositoryImpl implements ChatRepository {
  ChatRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.sessionManager,
  });

  final ChatRemoteDataSource remoteDataSource;
  final ChatLocalDataSource localDataSource;
  final ChatSessionManager sessionManager;

  @override
  String? get currentUserId => localDataSource.userId;

  @override
  Future<Result<AppError, List<Conversation>>> fetchConversations() async {
    try {
      final dtos = await remoteDataSource.getConversations(
        const GetConversationsRequest(limit: 100),
      );
      await localDataSource.cacheConversations(dtos);
      return Result.data(dtos.map((e) => e.toEntity()).toList());
    } catch (e) {
      return Result.error(AppError(message: e.toString()));
    }
  }

  // ── Reactive Watchers ────────────────────────────────────────────

  @override
  Stream<List<Conversation>> watchConversations() {
    return localDataSource
        .watchConversations()
        .map((dtos) => dtos.map((e) => e.toEntity()).toList());
  }

  @override
  Stream<List<ChatMessage>> watchMessages(String conversationId, {int? limit}) {
    // Catch-up for specific conversation history
    _syncMessages(conversationId, limit: limit);
    
    return localDataSource
        .watchMessages(conversationId, limit: limit ?? 50)
        .map((dtos) => dtos.map((e) => e.toEntity()).toList());
  }

  @override
  Stream<TypingStatus?> watchTyping(String conversationId) {
    return sessionManager.typingStream
        .where((t) => t == null || t.conversationId == conversationId);
  }

  // ── Sync Logic (Internal) ────────────────────────────────────────

  Future<void> _syncMessages(String conversationId, {int? limit}) async {
    try {
      final dtos = await remoteDataSource.getMessages(
        GetMessagesRequest(conversationId: conversationId, limit: limit),
      );
      await localDataSource.cacheMessages(dtos);
    } catch (_) {}
  }

  // ── Mutations ────────────────────────────────────────────────────

  @override
  Future<Result<AppError, ChatMessage>> sendManualMessage({
    required String conversationId,
    required String body,
  }) async {
    final tempId = 'temp_${DateTime.now().millisecondsSinceEpoch}';
    final optimisticDto = ChatMessageDto(
      id: tempId,
      conversationId: conversationId,
      body: body,
      senderType: SenderType.DISPATCHER,
      senderName: 'You',
      createdAt: DateTime.now(),
    );

    try {
      await localDataSource.cacheMessage(optimisticDto);
      final remoteDto = await remoteDataSource.sendManualMessage(
        SendMessageRequest(conversationId: conversationId, body: body),
      );
      await localDataSource.replaceTempMessage(tempId, remoteDto);
      return Result.data(remoteDto.toEntity());
    } catch (e) {
      await localDataSource.cacheMessage(
        optimisticDto.copyWith(status: MessageStatus.FAILED),
      );
      return Result.error(AppError(message: e.toString()));
    }
  }

  @override
  Future<Result<AppError, ChatMessage>> sendMediaMessage({
    required String conversationId,
    required String mediaUrl,
    String? caption,
  }) async {
    final tempId = 'temp_media_${DateTime.now().millisecondsSinceEpoch}';
    final optimisticDto = ChatMessageDto(
      id: tempId,
      conversationId: conversationId,
      body: caption ?? '',
      senderType: SenderType.DISPATCHER,
      senderName: 'You',
      mediaUrl: mediaUrl,
      createdAt: DateTime.now(),
    );

    try {
      await localDataSource.cacheMessage(optimisticDto);
      final remoteDto = await remoteDataSource.sendMediaMessage(
        SendMediaMessageRequest(
          conversationId: conversationId,
          mediaUrl: mediaUrl,
          caption: caption,
        ),
      );
      await localDataSource.replaceTempMessage(tempId, remoteDto);
      return Result.data(remoteDto.toEntity());
    } catch (e) {
      await localDataSource.cacheMessage(
        optimisticDto.copyWith(status: MessageStatus.FAILED),
      );
      return Result.error(AppError(message: e.toString()));
    }
  }

  @override
  Future<Result<AppError, bool>> toggleAutoReply({
    required String conversationId,
    required bool enabled,
  }) async {
    try {
      final success = await remoteDataSource.toggleAi(
        ToggleAiRequest(conversationId: conversationId, enabled: enabled),
      );
      return Result.data(success);
    } catch (e) {
      return Result.error(AppError(message: e.toString()));
    }
  }

  @override
  Future<Result<AppError, ChatMessage>> deleteMessage(String messageId) async {
    try {
      final dto = await remoteDataSource.deleteMessage(messageId);
      await localDataSource.softDeleteMessage(messageId);
      return Result.data(dto.toEntity().copyWith(isDeleted: true));
    } catch (e) {
      return Result.error(AppError(message: e.toString()));
    }
  }

  @override
  Future<Result<AppError, bool>> sendTypingIndicator(
    String conversationId,
  ) async {
    try {
      final success = await remoteDataSource.sendTypingIndicator(
        conversationId,
      );
      return Result.data(success);
    } catch (e) {
      return Result.error(AppError(message: e.toString()));
    }
  }
}
