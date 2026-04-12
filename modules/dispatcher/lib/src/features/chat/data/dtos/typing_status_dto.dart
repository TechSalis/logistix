class TypingStatusDto {
  const TypingStatusDto({
    required this.conversationId,
    required this.isTyping,
    this.senderName,
    this.senderType,
    this.senderId,
  });

  factory TypingStatusDto.fromJson(Map<String, dynamic> json) {
    return TypingStatusDto(
      conversationId: json['conversationId'] as String,
      isTyping: json['isTyping'] as bool,
      senderName: json['senderName'] as String?,
      senderType: json['senderType'] as String?,
      senderId: json['senderId'] as String?,
    );
  }

  final String conversationId;
  final bool isTyping;
  final String? senderName;
  final String? senderType;
  final String? senderId;

  Map<String, dynamic> toJson() {
    return {
      'conversationId': conversationId,
      'isTyping': isTyping,
      'senderName': senderName,
      'senderType': senderType,
      'senderId': senderId,
    };
  }
}
