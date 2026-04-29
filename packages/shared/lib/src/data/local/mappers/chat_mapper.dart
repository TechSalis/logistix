import 'package:drift/drift.dart';
import 'package:shared/shared.dart';

extension ConversationRowX on ConversationRow {
  Conversation toEntity() {
    return Conversation(
      id: id,
      platform: ChatPlatform.values.firstWhere(
        (e) => e.name == platform,
        orElse: () => ChatPlatform.WHATSAPP,
      ),
      platformId: platformId,
      createdAt: createdAt,
      updatedAt: updatedAt,
      autoReplyEnabled: autoReplyEnabled,
      customerName: customerName,
      companyId: companyId,
      lastMessageId: lastMessageId,
      lastMessageBody: lastMessageBody,
      lastMessageSenderType: lastMessageSenderType != null
          ? SenderType.values.firstWhere((e) => e.name == lastMessageSenderType)
          : null,
      lastMessageIsDeleted: lastMessageIsDeleted,
    );
  }
}

extension ConversationEntityX on Conversation {
  ConversationsCompanion toDriftCompanion() {
    return ConversationsCompanion(
      id: Value(id),
      platform: Value(platform.name),
      platformId: Value(platformId),
      lastMessageAt: Value(lastMessageAt),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      autoReplyEnabled: Value(autoReplyEnabled),
      customerName: Value(customerName),
      companyId: Value(companyId),
      lastMessageId: Value(lastMessageId),
      lastMessageBody: Value(lastMessageBody),
      lastMessageSenderType: Value(lastMessageSenderType?.name),
      lastMessageIsDeleted: Value(lastMessageIsDeleted),
    );
  }
}

extension ChatMessageRowX on ChatMessageRow {
  ChatMessage toEntity() {
    return ChatMessage(
      id: id,
      conversationId: conversationId,
      body: body,
      senderType: SenderType.values.firstWhere((e) => e.name == senderType),
      senderId: senderId,
      senderName: senderName,
      mediaUrl: mediaUrl,
      parentId: parentId,
      staleParentId: staleParentId,
      isDeleted: isDeleted,
      externalId: externalId,
      status: MessageStatus.values.firstWhere((e) => e.name == status),
      createdAt: createdAt,
    );
  }
}

extension ChatMessageEntityX on ChatMessage {
  ChatMessagesCompanion toDriftCompanion() {
    return ChatMessagesCompanion(
      id: Value(id),
      conversationId: Value(conversationId),
      body: Value(body),
      senderType: Value(senderType.name),
      senderId: Value(senderId),
      senderName: Value(senderName),
      mediaUrl: Value(mediaUrl),
      parentId: Value(parentId),
      staleParentId: Value(staleParentId),
      isDeleted: Value(isDeleted),
      externalId: Value(externalId),
      status: Value(status.name),
      createdAt: Value(createdAt),
    );
  }
}
