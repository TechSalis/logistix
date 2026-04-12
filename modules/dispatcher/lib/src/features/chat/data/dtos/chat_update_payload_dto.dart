import 'package:dispatcher/src/features/chat/data/dtos/chat_message_dto.dart';
import 'package:dispatcher/src/features/chat/data/dtos/typing_status_dto.dart';
import 'package:dispatcher/src/features/chat/domain/entities/chat_update.dart';

class ChatUpdatePayloadDto {
  const ChatUpdatePayloadDto({
    required this.type,
    this.message,
    this.typing,
  });

  factory ChatUpdatePayloadDto.fromJson(Map<String, dynamic> json) {
    return ChatUpdatePayloadDto(
      type: _typeFromString(json['type'] as String),
      message: json['message'] != null
          ? ChatMessageDto.fromJson(json['message'] as Map<String, dynamic>)
          : null,
      typing: json['typing'] != null
          ? TypingStatusDto.fromJson(json['typing'] as Map<String, dynamic>)
          : null,
    );
  }

  final ChatUpdateType type;
  final ChatMessageDto? message;
  final TypingStatusDto? typing;

  static ChatUpdateType _typeFromString(String value) {
    return ChatUpdateType.values.firstWhere(
      (e) => e.name == value.toUpperCase(),
      orElse: () => ChatUpdateType.MESSAGE,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type.name,
      'message': message?.toJson(),
      'typing': typing?.toJson(),
    };
  }
}
