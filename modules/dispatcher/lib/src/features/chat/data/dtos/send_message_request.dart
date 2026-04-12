class SendMessageRequest {
  const SendMessageRequest({
    required this.conversationId,
    required this.body,
  });

  factory SendMessageRequest.fromJson(Map<String, dynamic> json) {
    return SendMessageRequest(
      conversationId: json['conversationId'] as String,
      body: json['body'] as String,
    );
  }

  final String conversationId;
  final String body;

  Map<String, dynamic> toJson() {
    return {
      'conversationId': conversationId,
      'body': body,
    };
  }
}
