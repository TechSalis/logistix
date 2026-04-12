class GetMessagesRequest {
  const GetMessagesRequest({
    required this.conversationId,
    this.limit,
    this.before,
  });

  factory GetMessagesRequest.fromJson(Map<String, dynamic> json) {
    return GetMessagesRequest(
      conversationId: json['conversationId'] as String,
      limit: json['limit'] as int?,
      before: json['before'] as String?,
    );
  }

  final String conversationId;
  final int? limit;
  final String? before;

  Map<String, dynamic> toJson() {
    return {
      'conversationId': conversationId,
      'limit': limit,
      'before': before,
    };
  }
}
