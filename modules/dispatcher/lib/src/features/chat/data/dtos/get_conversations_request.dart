class GetConversationsRequest {
  const GetConversationsRequest({
    this.limit,
    this.offset,
  });

  factory GetConversationsRequest.fromJson(Map<String, dynamic> json) {
    return GetConversationsRequest(
      limit: json['limit'] as int?,
      offset: json['offset'] as int?,
    );
  }

  final int? limit;
  final int? offset;

  Map<String, dynamic> toJson() {
    return {
      'limit': limit,
      'offset': offset,
    };
  }
}
