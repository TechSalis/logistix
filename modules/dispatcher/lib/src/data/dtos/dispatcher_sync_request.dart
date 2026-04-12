class DispatcherSyncRequest {
  const DispatcherSyncRequest({
    this.since,
    this.limit,
    this.offset,
  });

  factory DispatcherSyncRequest.fromJson(Map<String, dynamic> json) {
    return DispatcherSyncRequest(
      since: (json['since'] as num?)?.toDouble(),
      limit: json['limit'] as int?,
      offset: json['offset'] as int?,
    );
  }

  final double? since;
  final int? limit;
  final int? offset;

  Map<String, dynamic> toJson() {
    return {
      'since': since,
      'limit': limit,
      'offset': offset,
    };
  }
}
