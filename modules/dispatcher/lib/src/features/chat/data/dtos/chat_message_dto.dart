import 'package:shared/shared.dart';

class ChatMessageDto {
  const ChatMessageDto({
    required this.id,
    required this.conversationId,
    required this.body,
    required this.senderType,
    required this.createdAt,
    this.senderId,
    this.senderName,
    this.metadata,
    this.mediaUrl,
    this.isDeleted = false,
    this.externalId,
    this.status = MessageStatus.SENT,
  });

  factory ChatMessageDto.fromJson(Map<String, dynamic> json) {
    return ChatMessageDto(
      id: json['id'] as String,
      conversationId: json['conversationId'] as String,
      body: json['body'] as String,
      senderType: _senderTypeFromString(json['senderType'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      senderId: json['senderId'] as String?,
      senderName: json['senderName'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
      mediaUrl: json['mediaUrl'] as String?,
      isDeleted: (json['isDeleted'] as bool?) ?? false,
      externalId: json['externalId'] as String?,
      status: _messageStatusFromString((json['status'] as String?) ?? 'SENT'),
    );
  }

  final String id;
  final String conversationId;
  final String body;
  final SenderType senderType;
  final DateTime createdAt;
  final String? senderId;
  final String? senderName;
  final Map<String, dynamic>? metadata;
  final String? mediaUrl;
  final bool isDeleted;
  final String? externalId;
  final MessageStatus status;

  static SenderType _senderTypeFromString(String value) {
    return SenderType.values.firstWhere(
      (e) => e.name == value.toUpperCase(),
      orElse: () => SenderType.SYSTEM,
    );
  }

  static MessageStatus _messageStatusFromString(String value) {
    return MessageStatus.values.firstWhere(
      (e) => e.name == value.toUpperCase(),
      orElse: () => MessageStatus.SENT,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'conversationId': conversationId,
      'body': body,
      'senderType': senderType.name,
      'createdAt': createdAt.toIso8601String(),
      'senderId': senderId,
      'senderName': senderName,
      'metadata': metadata,
      'mediaUrl': mediaUrl,
      'isDeleted': isDeleted,
      'externalId': externalId,
      'status': status.name,
    };
  }

  ChatMessage toEntity() => ChatMessage(
        id: id,
        conversationId: conversationId,
        body: body,
        senderType: senderType,
        senderId: senderId,
        senderName: senderName,
        createdAt: createdAt.toLocal(),
        metadata: metadata != null
            ? MessageMetadata(
                latitude: (metadata!['latitude'] as num?)?.toDouble(),
                longitude: (metadata!['longitude'] as num?)?.toDouble(),
              )
            : null,
        mediaUrl: mediaUrl,
        isDeleted: isDeleted,
        parentId: metadata?['parentId'] as String?,
        staleParentId: metadata?['staleParentId'] as String?,
        externalId: externalId,
        status: status,
      );

  ChatMessageDto copyWith({
    String? id,
    String? conversationId,
    String? body,
    SenderType? senderType,
    DateTime? createdAt,
    String? senderId,
    String? senderName,
    Map<String, dynamic>? metadata,
    String? mediaUrl,
    bool? isDeleted,
    String? externalId,
    MessageStatus? status,
  }) {
    return ChatMessageDto(
      id: id ?? this.id,
      conversationId: conversationId ?? this.conversationId,
      body: body ?? this.body,
      senderType: senderType ?? this.senderType,
      createdAt: createdAt ?? this.createdAt,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      metadata: metadata ?? this.metadata,
      mediaUrl: mediaUrl ?? this.mediaUrl,
      isDeleted: isDeleted ?? this.isDeleted,
      externalId: externalId ?? this.externalId,
      status: status ?? this.status,
    );
  }
}
