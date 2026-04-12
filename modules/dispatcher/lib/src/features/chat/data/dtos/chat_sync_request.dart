class ChatSyncRequest {
  const ChatSyncRequest({
    this.since,
    this.limit = 50,
    this.offset = 0,
  });

  final double? since;
  final int limit;
  final int offset;

  Map<String, dynamic> toJson() {
    return {
      'since': since,
      'limit': limit,
      'offset': offset,
    };
  }
}
