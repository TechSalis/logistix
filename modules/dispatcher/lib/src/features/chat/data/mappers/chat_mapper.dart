import 'package:dispatcher/src/features/chat/data/dtos/chat_message_dto.dart';
import 'package:dispatcher/src/features/chat/data/dtos/conversation_dto.dart';
import 'package:drift/drift.dart';
import 'package:shared/shared.dart';

extension ConversationToDto on Conversation {
  ConversationDto toDto({ChatMessageDto? lastMessage}) {
    return ConversationDto(
      id: id,
      platform: platform,
      platformId: platformId,
      lastMessageAt: lastMessageAt,
      createdAt: createdAt,
      updatedAt: updatedAt,
      autoReplyEnabled: autoReplyEnabled,
      customerName: customerName,
      lastMessage: lastMessage,
    );
  }
}

extension ConversationDtoToDrift on ConversationDto {
  ConversationsCompanion toDriftCompanion(String companyId) {
    return ConversationsCompanion.insert(
      id: id,
      platform: platform.name,
      platformId: platformId,
      lastMessageAt: lastMessageAt,
      createdAt: createdAt,
      updatedAt: updatedAt,
      companyId: companyId,
      autoReplyEnabled: Value(autoReplyEnabled),
      customerName: Value(customerName),
      lastMessageId: Value(lastMessage?.id),
      lastMessageBody: Value(lastMessage?.body),
      lastMessageSenderType: Value(lastMessage?.senderType.name),
      lastMessageIsDeleted: Value(lastMessage?.isDeleted),
    );
  }
}

extension ChatMessageToDto on ChatMessage {
  ChatMessageDto toDto() {
    return ChatMessageDto(
      id: id,
      conversationId: conversationId,
      body: body,
      senderType: senderType,
      senderId: senderId,
      senderName: senderName,
      mediaUrl: mediaUrl,
      isDeleted: isDeleted,
      createdAt: createdAt,
      externalId: externalId,
      status: status,
      metadata: {
        if (parentId != null) 'parentId': parentId,
        if (staleParentId != null) 'staleParentId': staleParentId,
      },
    );
  }
}

extension ChatMessageDtoToDrift on ChatMessageDto {
  ChatMessagesCompanion toDriftCompanion() {
    return ChatMessagesCompanion.insert(
      id: id,
      conversationId: conversationId,
      body: body,
      senderType: senderType.name,
      senderId: Value(senderId),
      senderName: Value(senderName),
      mediaUrl: Value(mediaUrl),
      parentId: Value(metadata?['parentId'] as String?),
      staleParentId: Value(metadata?['staleParentId'] as String?),
      isDeleted: Value(isDeleted),
      externalId: Value(externalId),
      status: Value(status.name),
      createdAt: createdAt,
    );
  }
}
