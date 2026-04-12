import 'package:dispatcher/src/features/chat/data/dtos/chat_message_dto.dart';
import 'package:dispatcher/src/features/chat/data/dtos/chat_update_payload_dto.dart';
import 'package:dispatcher/src/features/chat/data/dtos/conversation_dto.dart';
import 'package:dispatcher/src/features/chat/data/dtos/get_conversations_request.dart';
import 'package:dispatcher/src/features/chat/data/dtos/get_messages_request.dart';
import 'package:dispatcher/src/features/chat/data/dtos/send_media_message_request.dart';
import 'package:dispatcher/src/features/chat/data/dtos/send_message_request.dart';
import 'package:dispatcher/src/features/chat/data/dtos/toggle_ai_request.dart';
import 'package:dispatcher/src/features/chat/data/dtos/chat_sync_request.dart';
import 'package:dispatcher/src/features/chat/data/dtos/chat_sync_dto.dart';
import 'package:shared/shared.dart';

abstract class ChatRemoteDataSource {
  Future<List<ConversationDto>> getConversations(GetConversationsRequest request);
  Future<List<ChatMessageDto>> getMessages(GetMessagesRequest request);
  Future<ChatMessageDto> sendManualMessage(SendMessageRequest request);
  Future<ChatMessageDto> sendMediaMessage(SendMediaMessageRequest request);
  Future<bool> toggleAi(ToggleAiRequest request);
  Future<ChatMessageDto> deleteMessage(String messageId);
  Future<bool> sendTypingIndicator(String conversationId);

  Future<SyncManager> subscribeToChat({
    required void Function(ChatUpdatePayloadDto payload) onData,
    required Future<void> Function() onSync,
  });
  Future<ChatSyncDto> syncData(ChatSyncRequest request);
}

class ChatRemoteDataSourceImpl extends BaseRemoteDataSource
    implements ChatRemoteDataSource {
  ChatRemoteDataSourceImpl(super.gqlService, this.syncManager);

  final SyncManager syncManager;

  @override
  Future<SyncManager> subscribeToChat({
    required void Function(ChatUpdatePayloadDto payload) onData,
    required Future<void> Function() onSync,
  }) async {
    const subscriptionDoc = r'''
      subscription ChatSubscription($companyId: ID) {
        chatSubscription(companyId: $companyId) {
          type
          message {
            id
            conversationId
            body
            senderType
            senderId
            senderName
            metadata
            mediaUrl
            isDeleted
            status
            createdAt
          }
          typing {
            conversationId
            isTyping
            senderName
            senderId
            senderType
          }
        }
      }
    ''';

    // We don't pass companyId in variables anymore if it's filtered by session on backend,
    // but the backend Subscription resolver takes optional companyId for dispatcher filtering.
    // However, the session should be enough. Let's pass it for compatibility.
    await syncManager.startSubscription(
      subscriptionDocument: subscriptionDoc,
      variables: {}, // Backend uses the context/companyId from auth
      onData: (data) async {
        final payload = data['chatSubscription'] as Map<String, dynamic>;
        onData(ChatUpdatePayloadDto.fromJson(payload));
      },
      onSync: onSync,
    );

    return syncManager;
  }

  @override
  Future<bool> sendTypingIndicator(String conversationId) async {
    const mutationDoc = r'''
      mutation SendTypingIndicator($conversationId: ID!) {
        sendTypingIndicator(conversationId: $conversationId)
      }
    ''';

    final result = await mutate<bool>(
      mutationDoc,
      variables: {'conversationId': conversationId},
      key: 'sendTypingIndicator',
    );

    return result;
  }

  @override
  Future<List<ConversationDto>> getConversations(
    GetConversationsRequest request,
  ) async {
    const queryDoc = r'''
      query GetConversations($limit: Int, $offset: Int) {
        conversations(limit: $limit, offset: $offset) {
          id
          platform
          platformId
          autoReplyEnabled
          lastMessageAt
          createdAt
          updatedAt
          customerName
          lastMessage {
            id
            conversationId
            body
            senderType
            senderId
            senderName
            metadata
            mediaUrl
            isDeleted
            createdAt
          }
        }
      }
    ''';

    final result = await query<List<dynamic>>(
      queryDoc,
      variables: request.toJson(),
      key: 'conversations',
    );

    return result
        .map((json) => ConversationDto.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<ChatMessageDto>> getMessages(GetMessagesRequest request) async {
    const queryDoc = r'''
      query GetMessages($conversationId: ID!, $limit: Int, $before: ID) {
        messages(conversationId: $conversationId, limit: $limit, before: $before) {
          id
          conversationId
          body
          senderType
          senderId
          senderName
          metadata
          mediaUrl
          isDeleted
          createdAt
        }
      }
    ''';

    final result = await query<List<dynamic>>(
      queryDoc,
      variables: request.toJson(),
      key: 'messages',
    );

    return result
        .map((json) => ChatMessageDto.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<ChatMessageDto> sendManualMessage(SendMessageRequest request) async {
    const mutationDoc = r'''
      mutation SendManualMessage($conversationId: ID!, $body: String!) {
        sendManualMessage(conversationId: $conversationId, body: $body) {
          id
          conversationId
          body
          senderType
          senderId
          senderName
          metadata
          mediaUrl
          isDeleted
          createdAt
        }
      }
    ''';

    final result = await mutate<Map<String, dynamic>>(
      mutationDoc,
      variables: request.toJson(),
      key: 'sendManualMessage',
    );

    return ChatMessageDto.fromJson(result);
  }

  @override
  Future<bool> toggleAi(ToggleAiRequest request) async {
    const mutationDoc = r'''
      mutation ToggleAutoReply($conversationId: ID!, $enabled: Boolean!) {
        toggleAutoReply(conversationId: $conversationId, enabled: $enabled)
      }
    ''';

    final result = await mutate<bool>(
      mutationDoc,
      variables: request.toJson(),
      key: 'toggleAutoReply',
    );

    return result;
  }

  @override
  Future<ChatMessageDto> deleteMessage(String messageId) async {
    const mutationDoc = r'''
      mutation DeleteMessage($messageId: ID!) {
        deleteMessage(messageId: $messageId) {
          id
          conversationId
          isDeleted
        }
      }
    ''';

    final result = await mutate<Map<String, dynamic>>(
      mutationDoc,
      variables: {'messageId': messageId},
      key: 'deleteMessage',
    );

    return ChatMessageDto.fromJson(result);
  }

  @override
  Future<ChatMessageDto> sendMediaMessage(
    SendMediaMessageRequest request,
  ) async {
    const mutationDoc = r'''
      mutation SendMediaMessage($conversationId: ID!, $mediaUrl: String!, $caption: String) {
        sendMediaMessage(conversationId: $conversationId, mediaUrl: $mediaUrl, caption: $caption) {
          id
          conversationId
          body
          senderType
          senderId
          senderName
          metadata
          mediaUrl
          isDeleted
          createdAt
        }
      }
    ''';

    final result = await mutate<Map<String, dynamic>>(
      mutationDoc,
      variables: request.toJson(),
      key: 'sendMediaMessage',
    );

    return ChatMessageDto.fromJson(result);
  }
}
