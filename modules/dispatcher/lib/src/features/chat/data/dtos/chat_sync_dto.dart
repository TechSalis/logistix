import 'package:dispatcher/src/features/chat/data/dtos/conversation_dto.dart';

class ChatSyncDto {
  const ChatSyncDto({
    required this.conversations,
    required this.deletedMessageIds,
    required this.lastUpdated,
  });

  factory ChatSyncDto.fromJson(Map<String, dynamic> json) {
    return ChatSyncDto(
      conversations: (json['conversations'] as List<dynamic>?)
              ?.map((e) => ConversationDto.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      deletedMessageIds: (json['deletedMessageIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      lastUpdated: (json['lastUpdated'] as num).toInt(),
    );
  }

  final List<ConversationDto> conversations;
  final List<String> deletedMessageIds;
  final int lastUpdated;

  Map<String, dynamic> toJson() {
    return {
      'conversations': conversations.map((e) => e.toJson()).toList(),
      'deletedMessageIds': deletedMessageIds,
      'lastUpdated': lastUpdated,
    };
  }
}
