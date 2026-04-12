class SendMediaMessageRequest {
  const SendMediaMessageRequest({
    required this.conversationId,
    required this.mediaUrl,
    this.caption,
  });

  factory SendMediaMessageRequest.fromJson(Map<String, dynamic> json) {
    return SendMediaMessageRequest(
      conversationId: json['conversationId'] as String,
      mediaUrl: json['mediaUrl'] as String,
      caption: json['caption'] as String?,
    );
  }

  final String conversationId;
  final String mediaUrl;
  final String? caption;

  Map<String, dynamic> toJson() {
    return {
      'conversationId': conversationId,
      'mediaUrl': mediaUrl,
      'caption': caption,
    };
  }
}
