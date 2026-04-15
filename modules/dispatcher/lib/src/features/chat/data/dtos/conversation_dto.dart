import 'package:dispatcher/src/features/chat/data/dtos/chat_message_dto.dart';
import 'package:shared/shared.dart';

class ConversationDto {
  const ConversationDto({
    required this.id,
    required this.platform,
    required this.platformId,
    required this.lastMessageAt,
    required this.createdAt,
    required this.updatedAt,
    this.autoReplyEnabled = true,
    this.lastMessage,
    this.customerName,
  });

  factory ConversationDto.fromJson(Map<String, dynamic> json) {
    return ConversationDto(
      id: json['id'] as String,
      platform: _platformFromString(json['platform'] as String),
      platformId: json['platformId'] as String,
      lastMessageAt: DateTime.parse(json['lastMessageAt'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      autoReplyEnabled: (json['autoReplyEnabled'] as bool?) ?? true,
      lastMessage: json['lastMessage'] != null
          ? ChatMessageDto.fromJson(json['lastMessage'] as Map<String, dynamic>)
          : null,
      customerName: json['customerName'] as String?,
    );
  }

  final String id;
  final ChatPlatform platform;
  final String platformId;
  final DateTime lastMessageAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool autoReplyEnabled;
  final ChatMessageDto? lastMessage;
  final String? customerName;

  static ChatPlatform _platformFromString(String value) {
    return ChatPlatform.values.firstWhere(
      (e) => e.name == value.toUpperCase(),
      orElse: () => ChatPlatform.WHATSAPP,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'platform': platform.name,
      'platformId': platformId,
      'lastMessageAt': lastMessageAt.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'autoReplyEnabled': autoReplyEnabled,
      'lastMessage': lastMessage?.toJson(),
      'customerName': customerName,
    };
  }

  Conversation toEntity() => Conversation(
        id: id,
        platform: platform,
        platformId: platformId,
        autoReplyEnabled: autoReplyEnabled,
        lastMessageId: lastMessage?.id,
        lastMessageBody: lastMessage?.body,
        lastMessageSenderType: lastMessage?.senderType,
        lastMessageIsDeleted: lastMessage?.isDeleted,
        createdAt: createdAt.toLocal(),
        updatedAt: updatedAt.toLocal(),
        customerName: customerName,
        companyId: '', // Will be filled by repository if needed
      );

      ConversationDto copyWith({
        String? id,
        ChatPlatform? platform,
        String? platformId,
        DateTime? lastMessageAt,
        DateTime? createdAt,
        DateTime? updatedAt,
        bool? autoReplyEnabled,
        ChatMessageDto? lastMessage,
        String? customerName,
      }) {
        return ConversationDto(
          id: id ?? this.id,
          platform: platform ?? this.platform,
          platformId: platformId ?? this.platformId,
          lastMessageAt: lastMessageAt ?? this.lastMessageAt,
          createdAt: createdAt ?? this.createdAt,
          updatedAt: updatedAt ?? this.updatedAt,
          autoReplyEnabled: autoReplyEnabled ?? this.autoReplyEnabled,
          lastMessage: lastMessage ?? this.lastMessage,
          customerName: customerName ?? this.customerName,
        );
      }
}
